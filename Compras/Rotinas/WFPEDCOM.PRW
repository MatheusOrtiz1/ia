#INCLUDE "TBICONN.CH "
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³WFPEDCOM   ºAutor  ³EVERTON FORTI      º Data ³  10/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WORKFLOW PARA VERIF. PEDIDO DE COMPRA EM ABERTO ENVIA EMAIL º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONASA                                                     º±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function WFPEDCOM()
Local nI
Private cCond		:= ''
Private aPedcom		:= {}
Private cFornece
Private cPara      	:= ''
Private cHtml      	:= ''
Private dData		:= Date()
Private dData1		:= Date()
dData := dData - 02
dData1 := dData - 30

PREPARE ENVIRONMENT EMPRESA "23" FILIAL "01"  MODULO "COM" TABLES "SC7,SE4,SA2"

dbSelectArea("SC7")//descrição da condicão de Pagamento
dbSetOrder(1)

While SC7->(!Eof())
	
	
	IF C7_DATPRF >= dData1 .and. C7_DATPRF <= dData
		IF C7_QUJE==0 .And. C7_QTDACLA==0   //aAdd(aCores,    { 'C7_QUJE==0 .And. C7_QTDACLA==0'   		, 'ENABLE'})	  //-- Pendente
			
			dbSelectArea('SE4')//descrição da condicão de Pagamento
			dbSetOrder(1)
			dbSeek(xFilial('SE4')+SC7->C7_COND)
			cCond := SE4->E4_DESCRI
			
			
			dbSelectArea('SA2')//descrição do Fornecedor
			dbSetOrder(1)
			dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA)
			cFornece := SA2->A2_NOME
			
			aAdd( aPedcom, {	SC7->C7_NUM	 	,; //1
			DtoS(SC7->C7_EMISSAO)	,;         //2
			DtoS(SC7->C7_DATPRF)	,;                 //3
			SC7->C7_FORNECE	,;                 //4
			SC7->C7_LOJA	,;                 //5
			SC7->C7_COND	,;                 //6
			SC7->C7_ITEM    ,;                 //7
			SC7->C7_PRODUTO ,;                 //8
			SC7->C7_DESCRI  ,;                 //9
			SC7->C7_UM  	 ,;                //10
			TRANSFORM(SC7->C7_QUANT,'@E 99,999,999.99')		,;
			TRANSFORM(SC7->C7_PRECO,'@E 99,999,999.99')		,;
			TRANSFORM(SC7->C7_VLDESC,'@E 99,999,999.99')	,;
			TRANSFORM(SC7->C7_TOTAL,'@E 99,999,999.99')		,;
			SC7->C7_OBS		})
			
		Endif
	Endif
	SC7->(dbSkip(1))
Enddo

If Len(aPedcom) > 0
	
	cHtml	:='  <HTML> '
	cHtml	+='  <HEAD> '
	cHtml	+='   <TITLE> ATENÇÃO - PEDIDO DE COMPRA EM ABERTO </TITLE>'
	cHtml	+='  </HEAD> '
	cHtml	+='  <BODY> '
	cHtml	+=' <img src="http://www.conasa.com/img/logo.png" alt="Logo" width="100" height="40" border="0"><br><br>'
	cHtml	+=' ATENÇÃO - PEDIDO DE COMPRA EM ABERTO <BR><BR>'
	cHtml	+=' <font size="2">Empresa: 		' + cEmpAnt + ' - ' + Posicione("SM0",1, cNumEmp, "M0_NOMECOM") + '</font><br><br>'
	cHtml	+='     <TABLE border ="1">' '
	For nI := 1 To Len(aPedcom)
		cHtml	+='   <TR> '
		cHtml	+=' <td align="center"> '
		cHtml	+=' <font size="2">Pedido: 		' + aPedcom[nI,01] + '</font>'
		cHtml	+=' <font size="2">Emissão: 		' + substr(aPedcom[nI,02],7,2) + '/' + substr(aPedcom[nI,02],5,2) + '/' + substr(aPedcom[nI,02],1,4) +'</font>'
		cHtml	+=' <font size="2">Entrega: 		' + substr(aPedcom[nI,03],7,2) + '/' + substr(aPedcom[nI,03],5,2) + '/' + substr(aPedcom[nI,03],1,4) +'</font>'
		cHtml	+=' <font size="2"> Fornecedor: 	' + aPedcom[nI,04] + aPedcom[nI,05] + ' - ' + cFornece + ' </font>'
//		cHtml	+=' <font size="2"> Condição de Pagamento: ' + aPedcom[nI,06] + ' - ' + cCond + '</font><BR>'
		cHtml	+=' <font size="2"> Observação: ' + aPedcom[nI,15] +  '</font><BR>'
		cHtml	+='   </TD> '		
		cHtml	+='   </TR> '
		cHtml	+=' '
		cHtml	+='  <BR>'
		cHtml	+='  <BR>'
	Next nI
	/*
	cHtml	+='     <TABLE border ="1">' '
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5"> ITEM </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> PRODUTO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> DESCRIÇÃO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> UN </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> QTD </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> PREÇO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> DESCONTO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> TOTAL </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> OBSERVAÇÃO </font></td>'
	cHtml	+='   </TR>'
	For nI := 1 To Len(aPedcom)
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedcom[nI,07] + '</font></td>'
	
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedcom[nI,08] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,09] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,10] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,11] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,12] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,13] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,14] + '</font></td>'
	cHtml	+=' '
	cHtml	+='   </TR>'
	Next nI
	*/
	cHtml	+='     </TABLE>' '
	cHtml	+='   </TABLE>'
	cHtml += '<I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
	cHtml	+='  </BODY>'
	cHtml	+=' </HTML>'
	
	ENVPDCOM()
	//msginfo("Enviado E-mail de Aprovação com Suecesso")
EndIf

Return Nil

Static Function ENVPDCOM()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Private cPass      := GETMV("MV_RELPSW")
Private cAccount   := GETMV("MV_RELACNT")
Private cServer    := GETMV("MV_RELSERV")
Private cUsrmail   := GETMV("MV_RELACNT")
Private csenha1    := GETMV("MV_RELAPSW")
Private cFile      :=""
//Private cPara 	   := "everton.forti@totvs.com.br"
Private cPara 	   := usrretmail(SUPERGETMV("MV_UWPED2"))
Private cAssunto   	:= 'TOTVS AVISO - Pedido de Compra Não Entregue '

IF EMPTY(cPara)
	cPara      :='diorgny@conasa.com'
	cAssunto   	:= 'TOTVS ERRO - MV_UWPED2 nao preenchido!  '
endif

If lResult
	// Verifica se o E-mail necessita de Autenticacao
	If lAutentica
		lRet := MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
	Else
		lRet := .T.
	Endif
Endif
If !EMPTY(cPara)
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou

	If lConectou
		
		MAILAUTH(cAccount, cPass)
		
		SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cHtml Attachment cFile Result lConectou
		
		If !lConectou

			GET MAIL ERROR cSmtpError

		Endif

	EndIf
	
	DISCONNECT SMTP SERVER
EndIf

Return
