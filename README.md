# usendgrid
Unit Delphi 7 para enviar email usando api v3 da sendgrid

//Unit usendgrid
//Autor : Antonio Carlos Nunes Júnior (Toninho Nunes)
//Propósito : Usar o módulo Json api V3 do SendGrid
//Falta Implementar Lotes de 1000 emails por envio no registro personalizations
//farei esta adaptação no próximo update, o mesmo envia anexos diversos
//Fiz para funcionar no Delphi 7

//Bibliotecas de Terceiros
// - Component Indy 10 - http://indy.fulgan.com/ZIP/
// - gpDelphiUnits para lidar com Unicode - http://17slon.com/gp/gp/gptextstream.htm
//   Existe no github a versão mais atual dessa library, porém não compila certo com o
//   Delphi 7 e baixei desse link que funciona normal.
//
// - Json Delphi Libray - https://sourceforge.net/projects/lkjson/ - Lidar com Json no
//   Delphi 7 