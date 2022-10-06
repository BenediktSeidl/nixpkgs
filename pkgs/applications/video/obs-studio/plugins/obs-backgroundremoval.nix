{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, obs-studio
, onnxruntime
, opencv
}:

stdenv.mkDerivation rec {
  pname = "obs-backgroundremoval";
  version = "0.5.0"; # TODO: not an official version, but current main branch!

  src = fetchFromGitHub {
    owner = "royshil";
    repo = "obs-backgroundremoval";
    rev = "cc9d4a5711f9388ed110230f9f793bb071577a23";
    sha256 = "sha256-xkVZ4cB642p4DvZAPwI2EVhkfVl5lJhgOQobjNMqpec=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio onnxruntime opencv ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DOnnxruntime_INCLUDE_DIRS=${onnxruntime.dev}/include/onnxruntime/core/session"
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/royshil/obs-backgroundremoval/commit/9e1303923043c205a086d93692dbea8162d002fd.diff";
      sha256 = "sha256-SwKjo5FJvcLq+CPuxsPIhZ3OBVf3KTVaYzd023hBsPU=";
    })
  ];

  prePatch = ''
    sed -i 's/version_from_git()/set(VERSION "${version}")/' CMakeLists.txt
  '';

  meta = with lib; {
    description = "OBS plugin to replace the background in portrait images and video";
    homepage = "https://github.com/royshil/obs-backgroundremoval";
    maintainers = with maintainers; [ puffnfresh ];
    license = licenses.mit;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
