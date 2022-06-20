FROM nixos/nix:2.7.0

RUN nix-env -f '<nixpkgs>' -iA \
    gnused \
    openssh \
    && nix-store --gc

RUN mkdir -m 1777 -p /tmp
RUN mkdir -p /etc/ssh /var/empty \
    && echo "sshd:x:498:65534::/var/empty:/run/current-system/sw/bin/nologin" >> /etc/passwd \
    && cp /root/.nix-profile/etc/ssh/sshd_config /etc/ssh \
    && sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && sed -i '/^PermitEmptyPasswords/d' /etc/ssh/sshd_config \
    && echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config \
    && sed -i '/^UsePAM/d' /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N "" -t dsa \
    && echo "export NIX_PATH=$NIX_PATH" >> /etc/bashrc \
    && echo "export NIX_SSL_CERT_FILE=$NIX_SSL_CERT_FILE" >> /etc/bashrc \
    && echo "export PATH=$PATH" >> /etc/bashrc \
    && echo "source /etc/bashrc" >> /etc/profile

RUN "/root/.nix-profile/bin/passwd -d root

EXPOSE 22
CMD ["/root/.nix-profile/bin/sshd", "-D", "-e"]