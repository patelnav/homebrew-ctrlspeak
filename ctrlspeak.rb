class Ctrlspeak < Formula
  desc "Minimal speech-to-text utility for macOS"
  homepage "https://github.com/patelnav/ctrlspeak"
  url "https://github.com/patelnav/ctrlspeak/archive/refs/tags/v1.3.6.tar.gz"
  sha256 "eb979daa32c03ff0a20aaad777096698b3713bd90c089f096cfd82613ae33827"
  license "MIT"
  head "file:///Users/navpatel/Developer/ctrlspeak", using: :git, branch: "main"

  depends_on "python@3.11" # Using Python 3.11 as it's more stable in Homebrew

  option "with-nvidia", "Install support for NVIDIA models"
  option "with-whisper", "Install support for Whisper models"

  def install
    # Set up virtualenv
    venv = libexec/"venv"
    system "python3.11", "-m", "venv", venv

    # Check for uv
    uv_executable = nil
    begin
      uv_formula = Formula["uv"]
      if uv_formula&.any_version_installed?
        uv_executable = uv_formula.opt_bin/"uv"
      end
    rescue
      uv_executable = nil
    end
    uv_executable ||= Pathname.new(HOMEBREW_PREFIX)/"opt"/"uv"/"bin"/"uv"

    ohai "Starting package installation - this may take several minutes"

    if uv_executable&.exist?
      ohai "Using uv for package installation"
      with_env("VIRTUAL_ENV" => venv) do
        # Install requirements.txt first
        ohai "Installing core requirements"
        system uv_executable, "pip", "install", "-r", "requirements.txt", "--verbose"
        system uv_executable, "pip", "install", "-r", "requirements-mlx.txt", "--verbose"

        if build.with? "nvidia"
          ohai "Installing NVIDIA requirements"
          system uv_executable, "pip", "install", "-r", "requirements-nvidia.txt", "--verbose"
        end

        if build.with? "whisper"
          ohai "Installing Whisper requirements"
          system uv_executable, "pip", "install", "-r", "requirements-whisper.txt", "--verbose"
        end
      end
    else
      ohai "Using pip for package installation"
      system venv/"bin/pip", "install", "--upgrade", "pip", "-v"
      
      # Install requirements.txt first
      ohai "Installing core requirements"
      system venv/"bin/pip", "install", "-r", "requirements.txt", "-v"
      system venv/"bin/pip", "install", "-r", "requirements-mlx.txt", "-v"

      if build.with? "nvidia"
        ohai "Installing NVIDIA requirements"
        system venv/"bin/pip", "install", "-r", "requirements-nvidia.txt", "-v"
      end

      if build.with? "whisper"
        ohai "Installing Whisper requirements"
        system venv/"bin/pip", "install", "-r", "requirements-whisper.txt", "-v"
      end
    end

    ohai "Copying application files"
    # Copy all Python files and necessary directories/files
    libexec.install Dir["*.py"]
    libexec.install "utils"
    libexec.install "models"
    libexec.install "on.wav"
    libexec.install "off.wav"

    ohai "Creating wrapper script"
    # Create a wrapper script that sets up the Python path correctly
    # and also sets the DYLD_LIBRARY_PATH to find the torch and torchaudio libraries
    (bin/"ctrlspeak").write <<~EOS
      #!/bin/bash
      source "#{venv}/bin/activate"
      # Set the Python path to include the libexec directory
      export PYTHONPATH="#{libexec}:$PYTHONPATH"
      # Set the dynamic library path to find the torch and torchaudio libraries
      TORCH_LIB_PATH="#{venv}/lib/python3.11/site-packages/torch/lib"
      TORCHAUDIO_LIB_PATH="#{venv}/lib/python3.11/site-packages/torchaudio/lib"
      # Add both library paths to DYLD_LIBRARY_PATH
      export DYLD_LIBRARY_PATH="$TORCH_LIB_PATH:$TORCHAUDIO_LIB_PATH:$DYLD_LIBRARY_PATH"
      # Run the script
      python "#{libexec}/ctrlspeak.py" "$@"
    EOS

    # Make the wrapper executable
    chmod 0755, bin/"ctrlspeak"
    ohai "Installation complete!"
  end

  def caveats
    <<~EOS
      To use ctrlSPEAK, grant microphone and accessibility permissions:
      - System Preferences > Security & Privacy > Privacy
      - Add your terminal app (e.g., Terminal.app) to Microphone and Accessibility

      Run `ctrlspeak` in your terminal to start.

      Note: This formula is designed to work with Python 3.11.
      Future versions of Python (3.13+) may require additional dependencies.
    EOS
  end

  test do
    # Add a basic test to check if the script exists and is executable
    assert_path_exists bin/"ctrlspeak"
    assert_match(/bash/, (bin/"ctrlspeak").read)
  end
end