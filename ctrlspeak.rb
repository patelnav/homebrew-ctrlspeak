class Ctrlspeak < Formula
  desc "Minimal speech-to-text utility for macOS"
  homepage "https://github.com/patelnav/ctrlspeak"
  url "https://github.com/patelnav/ctrlspeak/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "33ae828507279d04799c1bd77a8f57c601163ad47a506726cc577206528b3e73"
  license "MIT"

  depends_on "python@3.11"  # Using Python 3.11 as it's more stable in Homebrew
  depends_on "uv" => :optional  # Optional dependency for faster package installation

  def install
    # Set up virtualenv
    venv = libexec/"venv"
    system "python3.11", "-m", "venv", venv

    # Print requirements for visibility
    ohai "Installing the following Python packages:"
    system "cat", "requirements.txt"
    
    # Add informational message about long-running process
    ohai "Starting package installation - this may take several minutes"
    opoo "Large packages like torch, torchaudio, and nemo_toolkit will be downloaded (~1GB)"
    
    # Determine whether to use uv or pip for package installation
    if build.with? "uv"
      # Use UV for faster package installation
      ohai "Using UV for faster package installation"
      system "uv", "pip", "install", "-r", "requirements.txt", "--prefix", venv, "--verbose"
    else
      # Use standard pip with maximum verbosity
      ohai "Upgrading pip - this is quick"
      system venv/"bin/pip", "install", "--upgrade", "pip", "-v"
      
      ohai "Installing packages - please be patient, torch and nemo_toolkit are large packages"
      system venv/"bin/pip", "install", "-r", "requirements.txt", "-v"
    end

    ohai "Copying application files"
    # Copy the main script and necessary files
    libexec.install "ctrlspeak.py"
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
    assert_predicate bin/"ctrlspeak", :exist?
    assert_predicate bin/"ctrlspeak", :executable?
  end
end 