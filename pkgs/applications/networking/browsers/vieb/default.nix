{ mkYarnPackage, fetchFromGitHub, electron, makeWrapper, makeDesktopItem, lib }:

mkYarnPackage rec {
  pname = "vieb";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "jelmerro";
    repo = pname;
    rev = version;
    sha256 = "sha256-0C2gD40nPgEZopGMPsd5ajwcwFRjcu4Xc2DTpEwSK4c=";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  yarnFlags = [ "--production" "--offline" ];

  nativeBuildInputs = [ makeWrapper ];

  desktopItem = makeDesktopItem {
    name = "vieb";
    exec = "vieb %U";
    icon = "vieb";
    desktopName = "Web Browser";
    genericName = "Web Browser";
    categories = "Network;WebBrowser;";
    mimeType = lib.concatStringsSep ";" [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

  postInstall = ''
    install -Dm0644 {${desktopItem},$out}/share/applications/vieb.desktop

    pushd $out/libexec/vieb/node_modules/vieb/app/img/icons
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/vieb.png
    done
    popd

    makeWrapper ${electron}/bin/electron $out/bin/vieb \
      --add-flags $out/libexec/vieb/node_modules/vieb/app
  '';

  distPhase = ":"; # disable useless $out/tarballs directory

  meta = with lib; {
    homepage = "https://vieb.dev/";
    description = "Vim Inspired Electron Browser";
    maintainers = with maintainers; [ gebner fortuneteller2k ];
    platforms = platforms.unix;
    license = licenses.gpl3Plus;
  };
}
