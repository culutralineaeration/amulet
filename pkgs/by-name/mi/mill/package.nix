{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mill";
  version = "0.12.3";

  src = fetchurl {
    url = "https://github.com/com-lihaoyi/mill/releases/download/${finalAttrs.version}/${finalAttrs.version}-assembly";
    hash = "sha256-hqzAuYadCciYPs/b6zloLUfrWF4rRtlBSMxSj7tLg7g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # this is mostly downloading a pre-built artifact
  preferLocal = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 "$src" "$out/bin/.mill-wrapped"
    # can't use wrapProgram because it sets --argv0
    makeWrapper "$out/bin/.mill-wrapped" "$out/bin/mill" \
      --prefix PATH : "${jre}/bin" \
      --set JAVA_HOME "${jre}"
    runHook postInstall
  '';

  doInstallCheck = true;
  # The default release is a script which will do an impure download
  # just ensure that the application can run without network
  installCheckPhase = ''
    $out/bin/mill --help > /dev/null
  '';

  meta = with lib; {
    homepage = "https://com-lihaoyi.github.io/mill/";
    license = licenses.mit;
    description = "Build tool for Scala, Java and more";
    mainProgram = "mill";
    longDescription = ''
      Mill is a build tool borrowing ideas from modern tools like Bazel, to let you build
      your projects in a way that's simple, fast, and predictable. Mill has built in
      support for the Scala programming language, and can serve as a replacement for
      SBT, but can also be extended to support any other language or platform via
      modules (written in Java or Scala) or through an external subprocesses.
    '';
    maintainers = with maintainers; [ scalavision zenithal ];
    platforms = lib.platforms.all;
  };
})
