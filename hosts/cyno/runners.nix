{ config, pkgs, lib, ... }:

let
  githubRunner = pkgs.github-runner.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/lib/externals/node20/bin
      ln -sf ${pkgs.nodejs_22}/bin/node $out/lib/externals/node20/bin/node
    '';
  });

  org = "https://github.com/nullptr-studios";
  runnerTokens = [
    "ARLKPLHOFCAPGG3ODGBYBNLKI3QGO"
    "ARLKPLA27CLNQS7OMHOUHSTKI3QGS"
    "ARLKPLFF5KLUJX6VSGRSVADKI3QGU"
    "ARLKPLE373FPO2JVD2HB4ZLKI3QGW"
    "ARLKPLA4XH7FEE4FQ3ZNRS3KI3QHE"
    "ARLKPLEK26FVA6SNYD2GEYDKI3QHG"
  ];
  indexed = lib.imap1 (i: token: { inherit i token; }) runnerTokens;

  vcpkgCachePath = "/var/cache/vcpkg";
  vcpkgDownloadsPath = "/home/xein/.vcpkg/root/downloads";
  runnerHome = i: "/var/lib/github-runners/nullptr-${toString i}";
in {
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      glibc
    ];
  };

  services.github-runners = lib.listToAttrs (map ({ i, ... }: {
    name = "nullptr-${toString i}";
    value = {
      enable = true;
      url = org;
      tokenFile = "/etc/github-runners/token-${toString i}";
      package = githubRunner;
      extraPackages = with pkgs; [ git curl wget gnutar zip unzip ];
    };
  }) indexed);

  systemd.tmpfiles.rules = [
    "d ${vcpkgCachePath} 0777 root root - -"
  ] ++ map ({ i, ... }: "d ${runnerHome i} 0755 github-runner-nullptr-${toString i} users - -") indexed;

  systemd.services = lib.listToAttrs (map ({ i, ...}: {
    name = "github-runner-nullptr-${toString i}";
    value = {
      environment = {
        HOME = lib.mkForce (runnerHome i);
        VCPKG_DEFAULT_BINARY_CACHE = vcpkgCachePath;
        VCPKG_DOWNLOADS = vcpkgDownloadsPath;
      };
      serviceConfig.ReadWritePaths = [ vcpkgCachePath vcpkgDownloadsPath (runnerHome i) ];
    };
  }) indexed);

  # Tokens stored in /etc/ with 0400 perms; source is in Nix store (world-readable).
  # For stronger isolation, migrate to agenix/sops-nix.
  environment.etc = lib.listToAttrs (map ({ i, token }: {
    name = "github-runners/token-${toString i}";
    value = {
      text = token;
      mode = "0400";
    };
  }) indexed);
}
