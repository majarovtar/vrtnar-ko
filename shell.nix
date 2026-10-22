{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python313Packages.requests
    pkgs.flutter
  ];

  shellHook = ''
    echo "Python environment loaded"
    echo "Python version: $(python --version)"
    echo "Pip version: $(pip --version)"
  '';
}