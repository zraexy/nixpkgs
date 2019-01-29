{ stdenv, cmake, extra-cmake-modules, plasma-framework, kwindowsystem, redshift, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "redshift-plasma-applet";
  version = "1.0.18";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "kotelnik";
    repo = "plasma-applet-redshift-control";
    rev = "v${version}";
    sha256 = "122nnbafa596rxdxlfshxk45lzch8c9342bzj7kzrsjkjg0xr9pq";
  }; # Future releases will be fetched from KDE sources

  patchPhase = ''
    substituteInPlace package/contents/ui/main.qml \
      --replace "redshiftCommand: 'redshift'" \
                "redshiftCommand: '${redshift}/bin/redshift'" \
      --replace "redshiftOneTimeCommand: 'redshift -O " \
                "redshiftOneTimeCommand: '${redshift}/bin/redshift -O " \
      --replace "redshift -x" \
                "${redshift}/bin/redshift -x" \
      --replace "killall redshift" \
                "killall .redshift-wrapp"

    substituteInPlace package/contents/ui/config/ConfigAdvanced.qml \
      --replace "'redshift -V'" \
                "'${redshift}/bin/redshift -V'"
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    plasma-framework
    kwindowsystem
  ];

  meta = with stdenv.lib; {
    description = "KDE Plasma 5 widget for controlling Redshift";
    homepage = https://phabricator.kde.org/source/plasma-redshift-control;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ benley zraexy ];
  };
}
