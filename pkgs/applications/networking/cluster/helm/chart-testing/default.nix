{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "chart-testing";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-b8U7zVvzewSxqX7RG7+FMAVytW4s2apNxR3krNJuiro=";
  };

  vendorSha256 = "sha256-z4hNGswxRMU40qkgwY3n516FiyaoeDaAE+CCla3TMkk=";

  postPatch = ''
    substituteInPlace pkg/config/config.go \
      --replace "\"/etc/ct\"," "\"$out/etc/ct\","
  '';

  ldflags = [
    "-w"
    "-s"
    "-X github.com/helm/chart-testing/v3/ct/cmd.Version=${version}"
    "-X github.com/helm/chart-testing/v3/ct/cmd.GitCommit=${src.rev}"
    "-X github.com/helm/chart-testing/v3/ct/cmd.BuildDate=19700101-00:00:00"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -Dm644 -t $out/etc/ct etc/chart_schema.yaml
    install -Dm644 -t $out/etc/ct etc/lintconf.yaml

    installShellCompletion --cmd ct \
      --bash <($out/bin/ct completion bash) \
      --zsh <($out/bin/ct completion zsh) \
      --fish <($out/bin/ct completion fish) \
  '';

  meta = with lib; {
    description = "A tool for testing Helm charts";
    homepage = "https://github.com/helm/chart-testing";
    license = licenses.asl20;
    maintainers = with maintainers; [ atkinschang ];
    mainProgram = "ct";
  };
}
