{
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "nix-docker";
    sshUser = "root";
    sshKey = "/etc/nix/docker_rsa";
    systems = [ "x86_64-linux" ];
    maxJobs = 2;
  }];
}
