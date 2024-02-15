#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH "
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function MT094END() 
/*
Operação a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)
*/
Private cHTML
Private cDocto := PARAMIXB[1] 
Private cTipo  := PARAMIXB[2]
Private nOpc   := PARAMIXB[3] 
Private cAprovado := " "
   
If nOpc == 1     
	cAprovado := "Aprovadoo"
endif
If nOpc == 2
	cAprovado := "Estornado"  
	
	IF RECLOCK("SC7",.F.)	
		SC7->C7_UWFDESC := ""
		MSUNLOCK()
	ENDIF
	
	ENVMAIL()
endif
If nOpc == 3
	cAprovado := "Aprovado"
	ENVMAIL()
endif
If nOpc == 4
	cAprovado := "Transferido"
	
	IF RECLOCK("SC7",.F.)	
		SC7->C7_UWFDESC := ""
		MSUNLOCK()
	ENDIF
	
	ENVMAIL()
endif       
If nOpc == 5
	cAprovado := "Rejeitado"

	IF RECLOCK("SC7",.F.)	
		SC7->C7_UWFDESC := ""
		MSUNLOCK()
	ENDIF

	ENVMAIL()
endif       
If nOpc == 6
	cAprovado := "Bloqueado"
	
	IF RECLOCK("SC7",.F.)	
		SC7->C7_UWFDESC := ""
		MSUNLOCK()
	ENDIF
	

endif

	ENVMAIL()
	
Return 

Static Function ENVMAIL()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Local cHtml		   := ""
Private cPass      := SUPERGETMV("MV_RELPSW")
Private cAccount   := SUPERGETMV("MV_RELACNT")
Private cServer    := SUPERGETMV("MV_RELSERV")
Private cUsrMail   := SUPERGETMV("MV_RELACNT")
Private csenha1    := SUPERGETMV("MV_RELAPSW") 
Private cPara      := SUPERGETMV("MV_UWFPED1",.F.,"") 
//Private cPara      := usrretmail(SC7->C7_USER)
Private cFile      :=""
Private cAssunto   	:= 'TOTVS - Pedido e Compra  ' + cAprovado +' - '+cNumemp+' - '+SM0->M0_NOME +' : ' +SM0->M0_FILIAL

dbSelectArea('SC1')
dbSetOrder(1)
IF dbSeek(xFilial('SC1')+SC7->C7_NUMSC)

	cPara += ';'+usrretmail(SC1->C1_USER)

ENDIF


cHtml:= ' <html>'
cHtml+= ' '
cHtml+= ' <head>'
cHtml+= ' <meta http-equiv="Content-Type"'
cHtml+= ' content="text/html; charset=iso-8859-1">'
cHtml+= ' <meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
cHtml+= ' <title>Contingência Liberada</title>'
cHtml+= ' </head>'
cHtml+= ' <style><!--body         '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px }.title       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px }.title1    '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px }.caber      ' 
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #C5D1CB; text-align: center; font-weight: bold }.cabel       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #C5D1CB; text-align: center; font-weight: bold }.cabec       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #C5D1CB; text-align: center; font-weight: bold }.itemr       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #ECF0EE; text-align: right }.iteml       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #ECF0EE; text-align: left }.itemc       '
cHtml+= ' { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; background-color: #ECF0EE; text-align: center }--></style>'
cHtml+= ' <body>'
cHtml+= '     <table border="0">'
cHtml+= '        <tr>   '
cHtml+= '           <td ><img src="http://www.totvs.com/sites/all/themes/totvs/logo.png" "></td>'
cHtml+= '           <td class="title" width="500" align="center"><MARQUEE BEHAVIOR=scroll width=100%>--Pedido de Compra '+cAprovado+' --</MARQUEE></tr>'
cHtml+= '     </table>'
cHtml+= ' <br><br>'
cHtml+= '<B>Empresa:'+SM0->M0_NOME +' : ' +SM0->M0_FILIAL+'</B>'
cHtml+= ' <h4><font class="cabe1">Pedido  por Sr.(a) '+UsrFullName (__CUSERID)+' </font></h4>'
cHtml+= ' <br>'
cHtml+= ' <font class="cabe1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Pedido n. '+ Alltrim(cDocto)+' foi ' + cAprovado +' </B>, prosseguir as rotinas normais do sistema. </font>'
cHtml+= ' <br><br>'
cHtml+= ' <br>     '
cHtml+= ' <font class="cabe1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Atenciosamente, </font>'
cHtml+= ' <br><br><br><br>'
cHtml+= ' <h4><font class="cabe1"><b>CONASA S/A </b></font><h4>'
cHtml+= ' <br>'
cHtml+= ' <I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
cHtml+= ' </body>'
cHtml+= ' </html>'
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
