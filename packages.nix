{
  pkgs,
  fetchzip ? pkgs.fetchzip,
  ...
}:
rec {
  chk-lib = {
    src = fetchGit {
      url = "git@github.com:jeapostrophe/chk";
      ref = "refs/master";
      rev = "be74d7bad039141c1c142c0590dead552445b260";
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

  racket-langserver = {
    src = fetchGit {
      url = "git@github.com:jeapostrophe/racket-langserver";
      ref = "refs/master";
      rev = "0bae2361279a7f77f64a039b786f65c7c3029ff7";
    };
    infos = [ { name = "racket-langserver"; } ];
    dependencies = [
      html-parsing
      chk-lib
    ];
  };

}
