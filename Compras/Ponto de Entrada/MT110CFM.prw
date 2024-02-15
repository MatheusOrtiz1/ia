#INCLUDE "TBICONN.CH "
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPROGRAMA  MT110CFM   บAUTOR  ณEVERTON FORTI	     บ DATA ณ  03/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ PE NA GRAVACAO DA SOLICITACAO DE COMPRAS				      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ CONASA	                                                  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT110CFM()
Local ExpC1  := PARAMIXB[1]
//Local ExpN1  := PARAMIXB[2]
Local cDTA	 := DTOC(DDATABASE)
LOCAL _AREA  	:= GETAREA()

//cDTA := DTOC(cDTA)

IF PARAMIXB[2]== 1
	// Valida็๕es do Usuแrio
	
	cHtml	:='  <HTML> '
	cHtml	+='  <HEAD> '
	cHtml	+='   <TITLE> ATENวรO - APROVADA SOLICITAวรO DE COMPRA </TITLE>'
	cHtml	+='  </HEAD> '
	cHtml	+='  <BODY> '
	cHtml	+=' <img src="http://www.conasa.com/img/logo.png" alt="Logo" width="200" height="60" border="0"><br><br>'
	cHtml	+=' ATENวรO -	APROVADA SOLICITAวรO DE COMPRA <BR><BR>'
	cHtml	+=' <font size="2">Empresa: 		' + cEmpAnt + ' - ' + Posicione("SM0",1, cNumEmp, "M0_NOMECOM") + '</font><br>'
	cHtml	+=' '
	cHtml	+='   <BR>'
	cHtml	+='     <BR>'
	cHtml	+='     <TABLE border ="1">' '
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5"> DATA </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> APROVADOR </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> SOCLICITAวรO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> OBSERVAวรO </font></td>'
	cHtml	+='   </TR>'
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5">' + substr(cDTA,1,4) + substr(cDTA,5,2) + substr(cDTA,7,4) + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + cUserName + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + ExpC1 + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + "Solicita็ใo de Compra Aprovada" + '</font></td>'
	
	cHtml	+=' '
	cHtml	+='   </TR>'
	cHtml	+='   </TABLE>'
	cHtml 	+= '<I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
	cHtml	+='  </BODY>'
	cHtml	+=' </HTML>'

dbSelectArea('SY1')
dbSetOrder(1)
dbGoTop()

WHILE SY1->(!Eof())
	
	cPara := usrretmail(SY1->Y1_USER)+';'
	
	SY1->(dbSkip())
Enddo	
	
	ENVTRU()
ENDIF  
RESTAREA(_AREA)

Return Nil


Static Function ENVTRU()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Private cPass      := GETMV("MV_RELPSW")
Private cAccount   := GETMV("MV_RELACNT")
Private cServer    := GETMV("MV_RELSERV")
Private cUsrmail   := GETMV("MV_RELACNT")
Private csenha1    := GETMV("MV_RELAPSW")
Private cFile      :=""
Private cAssunto   	:= 'TOTVS AVISO - Solicita Aprova็ใo de Solicita็ใo de Compra  '

IF EMPTY(cPara)
	cPara      :='everton.forti@totvs.com.br'//'diorgny@conasa.com'
	cAssunto   	:= 'TOTVS ERRO - Pedido de Compra sem Grupo de Aprova็ใo  '
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


RETURN()
