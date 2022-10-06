{ lib, obs-studio, symlinkJoin, makeWrapper }:

{ plugins ? [] }:

symlinkJoin {
  name = "wrapped-${obs-studio.name}";

  nativeBuildInputs = [ makeWrapper ];
  paths = [ obs-studio ] ++ plugins;

  postBuild = with lib;
    let
      # Some plugins needs extra environment, see obs-gstreamer for an example.
      pluginArguments =
        lists.concatMap (plugin: plugin.obsWrapperArguments or []) plugins;

      pluginsJoined = symlinkJoin {
        name = "obs-studio-plugins";
        paths = [ obs-studio ] ++ plugins;
      };

      wrapCommandLine = [
          "wrapProgram"
          "$out/bin/obs"
          ''--set OBS_PLUGINS_PATH "${pluginsJoined}/lib/obs-plugins"''
          ''--set OBS_PLUGINS_DATA_PATH "${pluginsJoined}/share/obs/obs-plugins"''
        ] ++ pluginArguments;
    in ''
    ${concatStringsSep " " wrapCommandLine}
  '';

  inherit (obs-studio) meta;
  passthru = obs-studio.passthru // {
    passthru.unwrapped = obs-studio;
  };
}
