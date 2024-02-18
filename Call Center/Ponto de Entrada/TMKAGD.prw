#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH "
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Programa que gera workflow dos Agendamentos do Call Center  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONASA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKAGD()

Private aArray := {}
Private cLojaCli, cDescri, oProcess, oHtml
Private cEmail       
Private cUser
Private cNuser

PREPARE ENVIRONMENT EMPRESA "28"  FILIAL "01"

CQUERY := ""
CQUERY += " SELECT UA_FILIAL, UA_NUM, UA_CLIENTE, UA_LOJA, UA_CODCONT, UA_DESCNT, UA_OPERADO,UA_PROXLIG, UA_HRPEND, UA_CODOBS "
CQUERY += " FROM "+RETSQLNAME("SUA")+" SUA "
CQUERY += " WHERE UA_PROXLIG = "+DTOS(DATE())+""
CQUERY += " AND SUA.D_E_L_E_T_ =''"
CQUERY += " ORDER BY UA_OPERADO"
IF SELECT("STUDY")!=0
	STUDY->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "STUDY" 

CQUERY := ""
CQUERY += " SELECT UC_FILIAL, UC_CODIGO, UC_DATA, UC_CODCONT, UC_ENTIDAD, UC_CHAVE, UC_OPERADO, UC_PENDENT, UC_HRPEND, UC_CODOBS"
CQUERY += " FROM "+RETSQLNAME("SUC")+" SUC "
CQUERY += " WHERE UC_PENDENT = "+DTOS(DATE())+""
CQUERY += " AND SUC.D_E_L_E_T_ =''"
CQUERY += " ORDER BY UC_OPERADO"
IF SELECT("STUDY1")!=0
	STUDY1->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "STUDY1"

CQUERY := ""
CQUERY += " SELECT ACF_FILIAL, ACF_CODIGO, ACF_CLIENT, ACF_LOJA, ACF_CODCON, ACF_OPERAD, ACF_OPERA, ACF_STATUS, ACF_MOTIVO, ACF_DATA, ACF_CODOBS, ACF_PENDEN, ACF_HRPEND"
CQUERY += " FROM "+RETSQLNAME("ACF")+" ACF "
CQUERY += " WHERE ACF_PENDEN = "+DTOS(DATE())+""
CQUERY += " AND ACF.D_E_L_E_T_ =''"
CQUERY += " ORDER BY ACF_OPERAD"
IF SELECT("STUDY2")!=0
	STUDY2->(DBCLOSEAREA())
ENDIF
TCQUERY CQUERY NEW ALIAS "STUDY2"

//-------------------------SUA------------------------
dbSelectArea("STUDY")
dbGoTop()
While !STUDY->( EOF() )
	DBSelectArea("SU5")
	DBSetOrder(1)
	DBSeek(xFilial("SU5")+STUDY->UA_CODCONT)
	DBSelectArea("SU7")
	DBSetOrder(1)
	DBSeek(xFilial("SU7")+STUDY->UA_OPERADO)
	
	cUser := SU7->U7_CODUSU
	cNuser:= SU7->U7_NOME
	
	While ! STUDY->(EOF()) .AND. SU7->U7_COD == STUDY->UA_OPERADO
		AADD(aArray, {	STUDY->UA_OPERADO	,;
						STUDY->UA_DESCNT	,;
						SU5->U5_DDD			,;
						SU5->U5_FONE		,;
						SU5->U5_CELULAR		,;
						SU5->U5_FAX			,;
						STUDY->UA_HRPEND	,;
						SU5->U5_OBS			,;
						SU5->U5_EMAIL		})
		
		STUDY->(dbSkip())
	Enddo
		If Len(aArray) > 0
		EnvMail()
		aArray :={}
	EndIf
	
	
	//	STUDY->(dbSkip())
Enddo

//-------------------------SUC------------------------	
dbSelectArea("STUDY1")
dbGoTop()
While !STUDY1->( EOF() )
	DBSelectArea("SU5")
	DBSetOrder(1)
	DBSeek(xFilial("SU5")+STUDY1->UC_CODCONT)
	DBSelectArea("SU7")
	DBSetOrder(1)
	DBSeek(xFilial("SU7")+STUDY1->UC_OPERADO)
	
	cUser := SU7->U7_CODUSU
	cNuser:= SU7->U7_NOME
	
	While ! STUDY1->(EOF()) .AND. SU7->U7_COD == STUDY1->UC_OPERADO
		
	
		AADD(aArray, {	STUDY1->UC_OPERADO			,;
						SU5->U5_CONTAT	   			,;
						SU5->U5_DDD		   			,;
						SU5->U5_FONE	   			,;
						SU5->U5_CELULAR	   			,;
						SU5->U5_FAX		  			,;
						STUDY1->UC_HRPEND 			,;
   			   			MSMM(STUDY1->UC_CODOBS,80),;
						SU5->U5_EMAIL	  			})
		
		STUDY1->(dbSkip())
	Enddo	
	
	If Len(aArray) > 0
		EnvMail()
		aArray :={}
	EndIf
	
	
	//	STUDY->(dbSkip())
Enddo

//-------------------------SUC------------------------	
     
dbSelectArea("STUDY2")
dbGoTop()
While !STUDY2->( EOF() )
	DBSelectArea("SU5")
	DBSetOrder(1)
	DBSeek(xFilial("SU5")+STUDY2->ACF_CODCONT)
	DBSelectArea("SU7")
	DBSetOrder(1)
	DBSeek(xFilial("SU7")+STUDY2->ACF_OPERADO)
	
	cUser := SU7->U7_CODUSU
	cNuser:= SU7->U7_NOME
	
	While ! STUDY2->(EOF()) .AND. SU7->U7_COD == STUDY2->ACF_OPERAD
		
	
		AADD(aArray, {	STUDY2->ACF_OPERAD			,;
						SU5->U5_CONTAT	   			,;
						SU5->U5_DDD		   			,;
						SU5->U5_FONE	   			,;
						SU5->U5_CELULAR	   			,;
						SU5->U5_FAX		  			,;
						STUDY2->ACF_HRPEND 			,;
   			   			MSMM(STUDY2->ACF_CODOBS,80),;
						SU5->U5_EMAIL	  			})
		
		STUDY2->(dbSkip())
	Enddo	
	
	If Len(aArray) > 0
		EnvMail()
		aArray :={}
	EndIf
	
	
	//	STUDY->(dbSkip())
Enddo

SU7->(DBCLOSEAREA())
SUC->(DBCLOSEAREA())
SU5->(DBCLOSEAREA())
STUDY->(DBCLOSEAREA())
STUDY1->(DBCLOSEAREA())
STUDY2->(DBCLOSEAREA())

Return .T.


Static Function Envmail()
Local lResult      := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
Local nI
Private cMsg
Private cPass      := GETMV("MV_RELAPSW")
Private cAccount   := GETMV("MV_RELACNT")
Private cServer    := GETMV("MV_RELSERV")
Private cUsrMail   := GETMV("MV_RELACNT")
Private csenha     := GETMV("MV_RELAPSW")
//Private cPara      := "everton.forti@totvs.com.br"
Private cPara      := usrretmail(CuSER)
Private cFile      :=""


Private cAssunto   	:= 'Retornar ligação para o Cliente  '

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Inicia montagem do html com os dados da proposta de cotação recebida\processada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

cMsg := ""
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>Untitled Document</title>'
cMsg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cMsg += '<style type="text/css">'
cMsg += '<!--'
cMsg += '.style8 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
cMsg += '.style13 {color: #0033FF; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
cMsg += '-->'
cMsg += '</style>'
cMsg += '</head>'
cMsg += ' '
cMsg += '<body>'
cMsg += '<table width="500" border="0">'
cMsg += '  <tr>' 
cMsg += ' 	 <th width="120" bgcolor="#DFEFFF" scope="col">Agendamento de Ligação - Cliente </th>'
cMsg += '    <th width="100" height="40" bgcolor="#DFEFFF" scope="col"><img src="http://www.conasa.com/img/logo.png" alt="Logo" width="120" height="30" border="0"></th>'
cMsg += '  </tr>'
cMsg += '</table>'
cMsg += '<hr align="left" width="826">'
cMsg += '<table width="827" border="0">'
cMsg += '  <tr>'
cMsg += '    <th width="143" scope="col">Operador</th>'
cMsg += '    <th width="674" scope="col"><div align="left">'+cNuser+'</div></th>'
cMsg += '  </tr>'
cMsg += '</table>'
cMsg += '<table width="952" height="98" border="0">'
cMsg += '  <tr>'
cMsg += '    <th width="1017" height="94" scope="col"><blockquote>&nbsp;</blockquote>      <div align="center">'
cMsg += '        <table width="605" border="1" align="left" bordercolor="#333333">'
cMsg += '          <tr>'
cMsg += '            <th scope="col"><span class="style8">Operador</span></th>'
cMsg += '            <th scope="col"><span class="style8">Cliente</span></th>'
cMsg += '            <th scope="col"><span class="style8">DDD</span></th>'
cMsg += '            <th scope="col"><span class="style8">Telefone</span></th>'
cMsg += '            <th scope="col"><span class="style8">Ceular</span></th>'
cMsg += '            <th scope="col"><span class="style8">Fax</span></th>'
cMsg += '            <th scope="col"><span class="style8">Hora</span></th>'
cMsg += '            <th scope="col"><span class="style8">Observação</span></th>'
cMsg += '            <th scope="col"><span class="style8">E-Mail</span></th>'
cMsg += '          </tr>
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Processa todos os itens da proposta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI := 1 To Len(aArray)
	cMsg += '   <tr> '
	cMsg += '   <td align="center"> <font size="1,5">' + CHR(9) + aArray[nI,01] + '</font></td>'
	cMsg += '   <td align="center"> <font size="1,5">' + CHR(9) + aArray[nI,02] + '</font></td>'
	cMsg += '   <td align="center"> <font size="1,5">' + CHR(9) + aArray[nI,03] + '</font></td>'
	cMsg += '   <td align="center"> <font size="1,5">' + CHR(9) + aArray[nI,04] + '</font></td>'
	cMsg += '   <td align="right" > <font size="1,5">' + CHR(9) + aArray[nI,05] + '</font></td>'
	cMsg += '   <td align="right" > <font size="1,5">' + CHR(9) + aArray[nI,06] + '</font></td>'
	cMsg += '   <td align="right" > <font size="1,5">' + CHR(9) + aArray[nI,07] + '</font></td>'
	cMsg += '   <td align="right" > <font size="1,5">' + CHR(9) + aArray[nI,08] + '</font></td>'
	cMsg += '   <td align="right" > <font size="1,5">' + CHR(9) + aArray[nI,09] + '</font></td>'
	cMsg += '   </tr> '
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta o final do html com os dados da proposta do fornecedor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

cMsg += '          </tr>'
cMsg += '        </table>'
cMsg += '        </div>'
cMsg += '   </tr>'
cMsg += '</table>
cMsg += '<table width="950" height="25" border="0">'
cMsg += '  <tr>'
cMsg += '    <th scope="col"><div align="left"> </div></th>'
cMsg += '  </tr>'
cMsg += '</table>' 
cMsg += '<p>&nbsp;</p>'
cMsg += '<p>&nbsp;</p>'
cMsg += '<br>'
cMsg += '<I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Efetua o envio do e-mail 								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

If lResult
	// Verifica se o E-mail necessita de Autenticacao
	If lAutentica
		lRet := MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELAPSW"))
	Else
		lRet := .T.
	Endif
Endif
If !EMPTY(cPara)
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou

	If lConectou

		MAILAUTH(cAccount, cPass)
		
		SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cMsg Attachment cFile Result lConectou
		
		If !lConectou
			GET MAIL ERROR cSmtpError
		Endif
	EndIf
	
	DISCONNECT SMTP SERVER
EndIf

Return

