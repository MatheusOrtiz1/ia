#INCLUDE "TBICONN.CH "
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPROGRAMA  MTA110OK   ºAUTOR  ³EVERTON FORTI	     º DATA ³  29/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ PE NA GRAVACAO DA SOLICITACAO DE COMPRAS				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ CONASA	                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION MTA110OK()
Local XX,Ni
LOCAL cRet   	:= .T.
LOCAL _AREA  	:= GETAREA()
LOCAL _AREASC1 	:= SC1->(GETAREA())
LOCAL _AREACTT 	:= CTT->(GETAREA())
LOCAL _AREASAL 	:= SAL->(GETAREA())
Local cNumSC1 	:= cA110Num
Local dData		:= DTOC(DDATABASE)
Local aPedit	:= {}
//Local nPItem    
LOCAL MVUMTA110 := SuperGetMV("MV_UMTA110",.F.,"N") //Parametro para ativar\desativar envio e-mail
Private cPara   := ''
Private cHtml   := '' 

IF MVUMTA110 == "N"
	Return()
ENDIF

DBSELECTAREA("SC1")
DBSETORDER(1)
IF !DBSEEK(XFILIAL("SC1")+cNumSC1)
	
	For XX:=1 To Len(Acols)
		nPosdESC      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_DESCRI"}) 
		nposProd      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_PRODUTO"})  
		nPosItem      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_ITEM"})  
		nPosUm     	 := aScan(aHeader,{|x| AllTrim(x[2])=="C1_UM"}) 
		nPosQtd      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_QUANT"})  
		nPosObs      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_OBS"}) 
		nPosCC       := aScan(aHeader,{|x| AllTrim(x[2])=="C1_CC"}) 
		nPosDat      := aScan(aHeader,{|x| AllTrim(x[2])=="C1_DATPRF"}) 

		dbSelectArea('CTT')//descrição da CENTRO DE CUSTO
		dbSetOrder(1)
		dbSeek(xFilial('CTT')+aCols[XX,11])
		
		
		aAdd( aPedit, {	cNumSC1	 	,;							//1
		dData						,;							//2
		cusername					,;							//3
		aCols[XX,nPosItem]    		,; 							//4 - ITEM
		aCols[XX,nposProd] 			,;							//5 - PRRODUTO
		aCols[XX,nPosdESC]  		,;							//6 - DESC PROD
		aCols[XX,nPosUm]  			,;							// 7 - UM
		TRANSFORM(aCols[XX,nPosQtd],'@E 99,999,999.99'),; 		//8 - QUANTIDADE
		aCols[XX,nPosDat]  			,; 							//9 -  DATA
		aCols[XX,nPosCC]  			,; 							//10 -  C.CUSTO
		CTT->CTT_DESC01				,;							//11 - 
		aCols[XX,nPosObs]				}) 						//12 - OBSERVAÇÃO
		
	Next XX
ELSE
	RETURN()
ENDIF

//Busca Grupo de Aprovadores
dbSelectArea('SAL')
dbSetOrder(1)
dbGoTop()

WHILE SAL->(!Eof())
	
	cPara += usrretmail(SAL->AL_USER)+';'
	
	SAL->(dbSkip())
Enddo

If Len(aPedit) > 0
	
	cHtml	:='  <HTML> '
	cHtml	+='  <HEAD> '
	cHtml	+='   <TITLE> ATENÇÃO - NOVA SOLICITAÇÃO DE COMPRA INCLUIDO </TITLE>'
	cHtml	+='  </HEAD> '
	cHtml	+='  <BODY> '
	cHtml	+=' <img src="http://www.conasa.com/img/logo.png" alt="Logo" width="200" height="60" border="0"><br><br>'
	cHtml	+=' ATENÇÃO - NOVA SOLICITAÇÃO  DE COMPRA INCLUIDO <BR><BR>'
	cHtml	+=' <font size="2">Empresa: 		' + cEmpAnt + ' - ' + Posicione("SM0",1, cNumEmp, "M0_NOMECOM") + '</font><br>'
	cHtml	+=' <font size="2">Solicitação: 		' + aPedit[01][01] + '</font>'
	cHtml	+=' <font size="2">Emissão: 		' + substr(aPedit[01][02],1,4) + substr(aPedit[01][02],5,2) + substr(aPedit[01][02],7,4) +'</font>'
	cHtml	+=' <font size="2">Solicitante: 	' + UsrRetName(__cUserId) +'</font><BR>'
	cHtml	+=' '
	cHtml	+='   <BR>'
	cHtml	+='     <BR>'
	cHtml	+='     <TABLE border ="1">' '
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5"> ITEM </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> PRODUTO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> DESCRIÇÃO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> UN </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> QTD </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> C.CUSTO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> DESC. C.CUSTO </font></td>'
	cHtml	+=' <td align="center"> <font size="1,5"> OBSERVAÇÃO </font></td>'
	cHtml	+='   </TR>'
	For nI := 1 To Len(aPedit)
		cHtml	+='   <TR> '
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,04] + '</font></td>'
		
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,05] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,06] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,7] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,8] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,10] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,11] + '</font></td>'
		cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,12] + '</font></td>'
		cHtml	+=' '
		cHtml	+='   </TR>'
	Next nI
	cHtml	+='   </TABLE>'
	cHtml += '<I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
	cHtml	+='  </BODY>'
	cHtml	+=' </HTML>'
	
	ENVPCSAL()
	//msginfo("Enviado E-mail de Aprovação com Suecesso")
EndIf

RESTAREA(_AREA)
RESTAREA(_AREASC1)
RESTAREA(_AREACTT)
RESTAREA(_AREASAL)
Return(cRet)

Static Function ENVPCSAL()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Private cPass      := SuperGetMV("MV_RELPSW")
Private cAccount   := SuperGetMV("MV_RELACNT")
Private cServer    := SuperGetMV("MV_RELSERV")
Private cUsrmail   := SuperGetMV("MV_RELACNT")
Private csenha1    := SuperGetMV("MV_RELAPSW")
Private cFile      :=""
Private cAssunto   	:= 'TOTVS AVISO - Solicita Aprovação do Solicitação de Compra  '

IF EMPTY(cPara)
	cPara      :='everton.forti@totvs.com.br'//'diorgny@conasa.com'
	cAssunto   	:= 'TOTVS ERRO - Pedido de Compra sem Grupo de Aprovação  '
endif

//cPara      :='phurtbr@gmail.com'

If lResult
	// Verifica se o E-mail necessita de Autenticacao
	If lAutentica
		lRet := MailAuth(SuperGetMV("MV_RELACNT"),SuperGetMV("MV_RELPSW"))
	Else
		lRet := .T.
	Endif
Endif
If !EMPTY(cPara)
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou
	
	ConOut(".....CONNECT....")
	If lConectou
		conout(cAccount + " --> " + cPara + " Sobre --> " + cAssunto)
		
		MAILAUTH(cAccount, cPass)
		
		SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cHtml Attachment cFile Result lConectou
		
		If lConectou
			conout("Envio OK")
		Else
			GET MAIL ERROR cSmtpError
			conout("Erro de envio : " + cSmtpError)
		Endif
	Else
		conout('nao entrou conectou')
	EndIf
	
	DISCONNECT SMTP SERVER
EndIf


RETURN()
