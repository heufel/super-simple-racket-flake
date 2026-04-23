{
  pkgs,
  fetchgit ? pkgs.fetchgit,
  fetchzip ? pkgs.fetchzip,
  ...
}:
rec {
  chk-lib = {
    src = fetchgit {
      url = "https://github.com/jeapostrophe/chk";
      rev = "32fb635e19fa2dc2d9c35bac0964ab76dde1e89e";
      hash = "sha256-Qlk7FEcHwacXNxDGFpJUEc4bdd05aZjFcv6ijH8IGv0=";
    };
    infos = [
      rec {
        name = "chk-lib";
        path = name;
      }
      rec {
        name = "chk-doc";
        path = name;
      }
      rec {
        name = "chk";
        path = name;
      }
    ];
  };

  mcfly = {
    src = fetchzip {
      url = "https://www.neilvandyke.org/racket/mcfly.zip";
      hash = "sha256-gAA/Uqyis4FWkWj0mMim5mlFOr6QjpCUW71y/+lqNZM=";
    };
    infos = [ { name = "mcfly"; } ];
  };

  overeasy = {
    src = fetchzip {
      url = "https://www.neilvandyke.org/racket/overeasy.zip";
      hash = "sha256-3xgr35Ba5ngeu2aeew6vevTZeJA/JRy57QWcFBht3Zk=";
    };
    infos = [ { name = "overeasy"; } ];
    dependencies = [ mcfly ];
  };

  html-parsing = {
    src = fetchzip {
      url = "https://www.neilvandyke.org/racket/html-parsing.zip";
      hash = "sha256-a+EzAtYC0Jj+luddIcOXvelxe/dIp6E4s8b2Hr3oesI=";
    };
    infos = [ { name = "html-parsing"; } ];
    dependencies = [
      mcfly
      overeasy
    ];
  };

  fixw = {
    src = fetchgit {
      url = "https://github.com/6cdh/racket-fixw";
      rev = "b93ec4e13223533b1897e269f2245bad16fe3c45";
      hash = "sha256-PC+JTSmgz+LSQTasEAKXWidu1bOUroMtBoOeHMgpV5U=";
    };
    infos = [ { name = "fixw"; } ];
  };

  racket-langserver = {
    src = fetchgit {
      url = "https://github.com/jeapostrophe/racket-langserver";
      rev = "5cbf431c8e7e62c75b64b7b3a3a672d73daaa5f4";
      hash = "sha256-79C48QcBSbcEpTYBZGQ4dGMa2h/CCmED9zEVUiQuaZ8=";
    };
    infos = [ { name = "racket-langserver"; } ];
    dependencies = [
      html-parsing
      chk-lib
      fixw
    ];
  };

}
