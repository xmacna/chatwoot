# Fork operacional XMACNA

A branch `main` acompanha o Chatwoot v4.14.0 (`81cb75b`) com idempotência WhatsApp (`6b8bf66`) e prova de concorrência (`e9037073`). O antigo `develop` (`28e16f7`) é ancestral dessa versão; consolidar a main não atualiza o runtime além da versão já implantada.

A CI de testes CE inclui `main`. Workflows herdados que publicam imagens em `chatwoot/chatwoot` ou `ghcr.io/chatwoot` executam somente no repositório upstream; o fork publica candidatos imutáveis pelo comando `xmacna chatwoot publish-idempotency-image` no Elysium. Promover/voltar a versão de produção continua pelo `xmacna chatwoot runtime-cutover-idempotency`, com plano, backup e readback.

Em 19/09/2026, o readback confirmou HTTP 200 e Elastic Beanstalk Ready/Green na versão `xmacna-waid-81506b674c90-20260815T023841Z`, sem redeploy. O candidato pinado é `sha256:81506b674c903836da10d75cebbd36862a11b2c72e6aae26ea48211bd83bc47e`; rollback preparado: `xmacna-rollback-49a3909246d3-20260815T023841Z`.

A validação original de `e9037073` registrou 50 exemplos sem falhas, corrida com 20 threads, RuboCop e Zeitwerk. O log foi revalidado por SHA-256; alterações desta consolidação se limitam a CI e documentação. A evidência atual de runtime complementa essa prova por conteúdo, sem alegar nova execução dos specs Rails.
