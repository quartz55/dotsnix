{
  pkgs,
  python3,
  buildPythonApplication ? python3.pkgs.buildPythonApplication,
  python313Packages,
}:

buildPythonApplication rec {
  name = "proxmox-lxc-idmapper";
  version = "master";

  pyproject = true;
  build-system = [ python313Packages.setuptools ];

  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup

    setup(
      name='proxmox-lxc-idmapper',
      #packages=['run'],
      version='0.1.0',
      author='ddimick',
      description='Proxmox unprivileged container/host uid/gid mapping syntax tool',
      scripts=[
        'run.py',
      ],
      entry_points={
        # example: file some_module.py -> function main
        #'console_scripts': ['someprogram=some_module:main']
      },
    )
    EOF
  '';

  postInstall = ''
    mv -v $out/bin/run.py $out/bin/proxmox-lxc-idmapper
  '';

  src = pkgs.fetchFromGitHub {
    owner = "ddimick";
    repo = "${name}";
    rev = "844292b";
    sha256 = "sha256-rar7yWIp/9h7DtAgDa7hQo2du5xHZgWjvsRaZsz8q7M=";
  };

  meta = {
    homepage = "https://github.com/ddimick/proxmox-lxc-idmapper";
    description = "Proxmox unprivileged container/host uid/gid mapping syntax tool";
    maintainers = with pkgs.maintainers; [ quartz55 ];
  };
}
