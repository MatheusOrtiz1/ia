#INCLUDE "TBICONN.CH "
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MT120GOK   ºAutor  ³EVERTON FORTI      º Data ³  29/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTO DE ENTRADA NA INCLUSAO DO PEDIDO DE COMPRA ENVIA EMAILº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONASA                                                     º±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT120GOK()
Local nI
Local cA120Num
Local l120Inclui
Local l120Altera
Local l120Deleta
Local cFornece		:= ''
Local aPedit		:= {}
Local cCond			:= ''
Local cGrupo		:= ''
Private cPara      	:= ''
Private cHtml      	:= ''
Private cSoliCom   	:= ''

cA120Num	:= ParamIxb[1]
l120Inclui	:= ParamIxb[2]
l120Altera	:= ParamIxb[3]
l120Deleta	:= ParamIxb[4]

If l120Deleta

	dbSelectArea("SCR")
	dbSetOrder(1)
	If DBSEEK(xFilial("SCR")+"PC"+cA120Num,.T.)
		Do While ( !Eof() .And. SCR->CR_FILIAL == xFilial("SCR") .And. SCR->CR_NUM == cA120Num )
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf


endif
If l120Inclui
	If SC7->(dbSetOrder(1), dbSeek(xFilial("SC7")+cA120Num))
		
		cGrupo := SC7->C7_APROV
		
		dbSelectArea('SE4')//descrição da condicão de Pagamento
		dbSetOrder(1)
		dbSeek(xFilial('SE4')+SC7->C7_COND)
		cCond := SE4->E4_DESCRI
		
		dbSelectArea('SA2')//descrição do Fornecedor
		dbSetOrder(1)
		dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA)
		cFornece := SA2->A2_NOME
		
		While SC7->(!Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM = cA120Num
			                    
			
		dbSelectArea('CTT')//descrição da CENTRO DE CUSTO
		dbSetOrder(1)
		dbSeek(xFilial('CTT')+SC7->C7_CC)	
		
		dbSelectArea('AK5')//descrição da CONTA ORÇAMENTARIA
		dbSetOrder(1)
		dbSeek(xFilial('AK5')+SC7->C7_CO)		
	
			aAdd( aPedit, {	SC7->C7_NUM	 	,;
			DtoS(SC7->C7_EMISSAO)	,;
			SC7->C7_USER	,;
			SC7->C7_FORNECE	,;
			SC7->C7_LOJA	,;
			SC7->C7_COND	,;
			SC7->C7_ITEM    ,;
			SC7->C7_PRODUTO ,;
			SC7->C7_DESCRI  ,;                                           			
			SC7->C7_UM  	 ,;
			TRANSFORM(SC7->C7_QUANT,'@E 99,999,999.99')		,;
			TRANSFORM(SC7->C7_PRECO,'@E 99,999,999.99')		,;
			TRANSFORM(SC7->C7_VLDESC,'@E 99,999,999.99')	,;
			TRANSFORM(SC7->C7_TOTAL,'@E 99,999,999.99')		,;
			SC7->C7_CO  	 ,;
			AK5->AK5_DESCRI	 ,;
			SC7->C7_CC  	 ,;
			CTT->CTT_DESC01	 ,;
			SC7->C7_OBS		,;
			IF(EMPTY(SC7->C7_NUMSC),"Vazio",SC7->C7_NUMSC)	})
			
			
			SC7->(dbSkip(1))
		Enddo
	Endif
Endif

//Busca Grupo de Aprovadores
dbSelectArea('SAL')
dbSetOrder(1)
dbSeek(xFilial('SAL')+cGrupo)

WHILE SAL->(!Eof()).AND. cGrupo == SAL->AL_COD .AND. SAL->AL_NIVEL =="01"
	
	cPara += usrretmail(SAL->AL_USER)+';'
	
	SAL->(dbSkip(1))
Enddo

if EMPTY(SC7->C7_NUMSC)
                                                                                                           	
	cSoliCom:= "Vazio"
	cPara+= usrretmail(SC7->C7_USER)+';'	
	
else
	dbSelectArea('SC1')
	dbSetOrder(1)
	IF dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
		
		cPara+= usrretmail(SC1->C1_USER)+';'
		                                  
	ENDIF
endif 


If Len(aPedit) > 0

cHtml	:='  <HTML> '
cHtml	+='  <HEAD> '
cHtml	+='   <TITLE> ATENÇÃO - NOVO PEDIDO DE COMPRA INCLUIDO </TITLE>'
cHtml	+='  </HEAD> '
cHtml	+='  <BODY> '
cHtml	+=' <img src="https://suporte.totvs.com/totvs-portal-cliente-theme-AtitudeQ/images/logo.png" alt="Logo" width="100" height="40" border="0"><br><br>'
cHtml	+=' ATENÇÃO - NOVO PEDIDO DE COMPRA INCLUIDO <BR><BR>'
cHtml	+=' <font size="2">Empresa: 		' + cEmpAnt + ' - ' + Posicione("SM0",1, cNumEmp, "M0_NOMECOM") + '</font><br>'
cHtml	+=' <font size="2">Pedido: 		' + aPedit[01][01] + '</font>'
cHtml	+=' <font size="2">Solicitação: 		' + cSoliCom + '</font>'
cHtml	+=' <font size="2">Emissão: 		' + substr(aPedit[01][02],7,2) + '/' + substr(aPedit[01][02],5,2) + '/' + substr(aPedit[01][02],1,4) +'</font>'
cHtml	+=' <font size="2">        Solicitante: 	' + UsrRetName(aPedit[01][03]) +'</font><BR>'
cHtml	+=' <font size="2"> Fornecedor: 	' + aPedit[01][04] + aPedit[01][05] + ' - ' + cFornece + ' </font><BR>'
cHtml	+=' <font size="2"> Condição de Pagamento: ' + aPedit[01][06] + ' - ' + cCond + '</font><BR>'
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
cHtml	+=' <td align="center"> <font size="1,5"> PREÇO </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> DESCONTO </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> TOTAL </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> C.O. </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> C.O. Descrição </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> CC </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> CC Descrição </font></td>'
cHtml	+=' <td align="center"> <font size="1,5"> OBSERVAÇÃO </font></td>'
cHtml	+='   </TR>'
For nI := 1 To Len(aPedit)
	cHtml	+='   <TR> '
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,07] + '</font></td>'

	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,08] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,09] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,10] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,11] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,12] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,13] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,14] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,15] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,16] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,17] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,18] + '</font></td>'
	cHtml	+=' <td align="center"> <font size="1,5">' + CHR(9) + aPedit[nI,19] + '</font></td>'
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

Return Nil

Static Function ENVPCSAL()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Private cPass      := GETMV("MV_RELPSW")
Private cAccount   := GETMV("MV_RELACNT")
Private cServer    := GETMV("MV_RELSERV")
Private cUsrmail   := GETMV("MV_RELACNT")
Private csenha1    := GETMV("MV_RELAPSW")
Private cFile      :=""
Private cAssunto   	:= 'TOTVS AVISO - NOVO PEDIDO DE COMPRA INCLUIDO  '
                                            
IF EMPTY(cPara)
cPara      :='diorgny@conasa.com'	                                 
cAssunto   	:= 'TOTVS ERRO - Pedido de Compra sem Grupo de Aprovação  '
endif

//cPara      :='phurtbr@gmail.com'

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
