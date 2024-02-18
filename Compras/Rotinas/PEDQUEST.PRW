#include "PROTHEUS.CH"  
#include "TBICONN.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} PEDQUEST              Data. 03/12/2020
Workflow para questionamento do pedido de compras
//-------------------------------------------------------------------*/
User Function PEDQUEST()
Local oButton1
Local oButton2
//Local oGet1
Private  oDlg
Private cNumPed := ""
private cGet1 := ""
Private cTemp,cTemp1,cTemp2,cStatus := ""

IF FUNNAME() == "MATA121"

    cNumPed := SC7->C7_NUM
Else

    DBSELECTAREA("SC7")
    DBSETORDER(1)
    If SC7->(dbSeek(xFilial("SC7")+ AllTrim(SCR->CR_NUM) ) )	

        cNumPed := SC7->C7_NUM
    EndIf
ENDIF


IF EMPTY(cNumPed)
    Return()
ENDIF


DBSELECTARE("Z30")
DBSETORDER(1)
IF DBSEEK(xFilial("Z30")+cNumPed)

    cGet1 := Z30->Z30_QUEST
    cTemp1 := Z30->Z30_QUEST
Else
    IF RECLOCK("Z30",.T.)
        Z30->Z30_FILIAL := xFilial("Z30")
        Z30->Z30_NUM    := cNumPed
        
    MSUNLOCK()

        cGet1 := Z30->Z30_QUEST
        cTemp1 := Z30->Z30_QUEST
    EndIf
ENDIF




  DEFINE MSDIALOG oDlg TITLE "Questionar Pedido de Compras" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

    //@ 020, 031 MSGET oGet1 VAR cGet1 SIZE 230, 100 OF oDlg COLORS 0, 16777215 PIXEL
    @ 020,031 Get cGet1 Size 230,100 MEMO of oDlg Pixel
    @ 128, 222 BUTTON oButton1 PROMPT "Quetionar" SIZE 037, 012 OF oDlg PIXEL Action FRSalva()
    @ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()

  ACTIVATE MSDIALOG oDlg CENTERED


Return

Static Function FRSalva()
	IF	RecLock("Z30",.f.)
		Z30->Z30_QUEST := cGet1
		msunlock()               
		msginfo("Mensagem gravada com sucesso")
		ODLG:END()
	endif

    cCont := LEN(cTemp1)+1
    cCont2:= LEN(cGet1) 
    
    IF cCont2 < cCont
        cTemp2:= cGet1
    Else
        cTemp2:= Substr(Cget1,cCont,cCont2) 
        cTemp2:= Alltrim(cTemp2)
    ENDIF

    U_WFQUEST()

Return

User Function WFQUEST()

	Local oProcess 	:= Nil							//Objeto da classe TWFProcess.
	Local cMailId 	:= ""							//ID do processo gerado. 
    Local cHostWF1	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link.
    //Local cHostWF	:= "http://192.168.0.60:8089"			//URL configurado no ini para WF Link.
	Local cTo 		:= "everton.forti@totvs.com.br" 	//Destinatário de email.    
	Local cAssunto  := "Questionamento Pedido de Compras - "+cNumPed+" !"
	//PREPARE ENVIRONMENT EMPRESA "41" FILIAL "01"    
	
	cTo := usrretmail(SC7->C7_USER)
	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
                           
    cModHtm := MontaHtml()
	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o código e nome do processo.  
	//-------------------------------------------------------------------  
	oProcess := TWFProcess():New("000001", cAssunto)
    oProcess:cPriority := "3"
	//-------------------------------------------------------------------
	// Criamos a tafefa principal que será respondida pelo usuário.  
	//-------------------------------------------------------------------  
	oProcess:NewTask(cAssunto, "\workflow\WFPEDQUEST.html")

	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//-------------------------------------------------------------------  	   
	oProcess:oHtml:ValByName("TEXT_TIME", Time() )
    
    oProcess:ohtml:ValByName("PEDIDO",			SC7->C7_NUM)
    oProcess:ohtml:ValByName("ITEM",			SC7->C7_ITEM)
    oProcess:ohtml:ValByName("PRODUTO",			SC7->C7_PRODUTO)
    oProcess:ohtml:ValByName("DESCRICAO",		SC7->C7_DESCRI)
    oProcess:ohtml:ValByName("UM",			    SC7->C7_UM)
    oProcess:ohtml:ValByName("QUANT",			SC7->C7_QUANT)
    oProcess:ohtml:ValByName("PRECO",			SC7->C7_PRECO)
    oProcess:ohtml:ValByName("TOTAL",			SC7->C7_TOTAL)
    oProcess:ohtml:ValByName("OBS",		    	SC7->C7_OBS)
    oProcess:ohtml:ValByName("FORNECE",			SC7->C7_FORNECE)
    oProcess:ohtml:ValByName("LOJA",			SC7->C7_LOJA)
    oProcess:ohtml:ValByName("CCUSTO",			SC7->C7_CC)
    oProcess:ohtml:ValByName("DESCRICC",		SC7->C7_DESCCC)
    oProcess:ohtml:ValByName("CORC",			SC7->C7_CO)
    oProcess:ohtml:ValByName("DESCORC",			SC7->C7_DESCCO)
    oProcess:ohtml:ValByName("QUEST",		    cGet1)
    oProcess:ohtml:ValByName("EMAIL",		    usrretmail(__cuserid))   
    oProcess:ohtml:ValByName("NOMEQUEST",		CUSERNAME) 
    oProcess:ohtml:ValByName("CNOMEC7",		    usrfullname(SC7->C7_USER))
                         
	//-------------------------------------------------------------------
	// Informamos em qual diretório será gerado o formulário.  
	//-------------------------------------------------------------------  	 
	oProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	oProcess:bTimeOut 	:= {{"u_TMOUTQUEST()", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	oProcess:bReturn 	:= "U_RETQUEST()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	cMailID := oProcess:Start("\messenger\emp"+cEmpAnt+"\HTML\")//tarefa executada

	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 

	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	oProcess:NewTask("cAssunto", cModHtm)
	
	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//------------------------------------------------------------------- 
	//oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm") 
	oProcess:oHtml:ValByName("A_LINK", cHostWF1 + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm") 

	//-------------------------------------------------------------------
	// Informamos o destinatário do email contendo o link.  
	//------------------------------------------------------------------- 	
	oProcess:cTo 		:= cTo   
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	oProcess:cSubject	:= cAssunto

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//------------------------------------------------------------------- 	
	oProcess:Start("\messenger\emp"+cEmpAnt+"\"+"HTML")                                                            		
Return    

//-------------------------------------------------------------------
/*/   
Função executada no retorno do processo. 
/*/
//-------------------------------------------------------------------       
User Function RETQUEST( poProcess )  
	Local cTime 	:= ""
	Local cProcesso := ""  
	Local cTarefa	:= ""  
	Local cMailID	:= ""
	Local cNumPed   := ""
    Local cqUEST    := ""
    Local cResposta := ""
	//-------------------------------------------------------------------
	// Recuperamos a hora do processo utilizando o método RetByName.
	//------------------------------------------------------------------- 		
	cTime 		:= poProcess:oHtml:RetByName("TEXT_TIME") 
    cqUEST		:= poProcess:oHtml:RetByName("QUEST") 
    cNumPed		:= poProcess:oHtml:RetByName("PEDIDO") 
    cResposta	:= poProcess:oHtml:RetByName("cResposta")
    cMilQuest 	:= poProcess:oHtml:RetByName("EMAIL")
    cNomQuest 	:= poProcess:oHtml:RetByName("NOMEQUEST")
    cNomeSC7 	:= poProcess:oHtml:RetByName("CNOMEC7")
    if !empty(cResposta)
        DBSELECTARE("Z30")
        DBSETORDER(1)
        IF DBSEEK(xFilial("Z30")+alltrim(cNumPed))
            plinha := chr(13)+chr(10)
            IF RECLOCK("Z30",.F.)
                Z30->Z30_QUEST  := Z30->Z30_QUEST+plinha+cResposta
            MSUNLOCK()
            EndIf
        ENDIF

        envResp(cNumPed,cqUEST,cResposta,cMilQuest,cNomQuest,cNomeSC7)
    
    endif
 	//-------------------------------------------------------------------
	// Recuperamos o identificador do email utilizando o método RetByName.
	//------------------------------------------------------------------- 		
	cMailID		:= poProcess:oHtml:RetByName("WFMAILID") 
  
	//-------------------------------------------------------------------
	// Recuperamos o ID do processo através do atributo do processo.
	//------------------------------------------------------------------- 		
	cProcesso 	:= poProcess:FProcessID  
 
	//-------------------------------------------------------------------
	// Recuperamos o ID da tarefa através do atributo do processo.
	//------------------------------------------------------------------- 	 
	cTarefa		:= poProcess:FTaskID  

	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------                  
		
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} TMOUTQUEST - wfTimeout    
Função executada no timeout do processo. 
/*/
//-------------------------------------------------------------------
User Function TMOUTQUEST( poProcess )  
	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------               
 
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} WFPE007    
Permite customizar a mensagem de processamento do WF por link. 
/*/
//-------------------------------------------------------------------
User Function REQPE007()
	Local cHTML 		:= ""
	Local plSuccess		:= ParamIXB[1] 
	Local pcMessage  	:= ParamIXB[2]	
	//Local pcProcessID  	:= ParamIXB[3]
	
	If ( plSuccess ) 
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para sucesso no processamento. 
		//------------------------------------------------------------------- 
    	cHTML += 'Processamento executado com sucesso!'
    	cHTML += '<br>'
    	cHTML += pcMessage
	Else       
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para falha no processamento. 
		//------------------------------------------------------------------- 
		cHTML += 'Falha no processamento!'
    	cHTML += '<br>'
    	cHTML += pcMessage
	EndIf
Return cHTML

//-------------------------------------------------------------------
// Envia e-mail para Questionador
//-------------------------------------------------------------------

static function envResp(cNumPed,cqUEST,cResposta,cMilQuest,cNomQuest,cNomeSC7)

cCodProcesso := "ENVRESP"
cHtmlModelo := "\workflow\avisaquest.html"
cAssunto := "Resposta Questionamento"
oProcess := TWFProcess():New(cCodProcesso, cAssunto)
oProcess:cSubject := cAssunto
oProcess:NewTask(cAssunto, cHtmlModelo)
oProcess:ohtml:ValByName("PEDIDO",cNumPed)
oProcess:ohtml:ValByName("SM0EMP",SM0->M0_NOMECOM)
oProcess:ohtml:ValByName("QUEST",cqUEST)
oProcess:ohtml:ValByName("NOMEQUEST",cNomQuest)
oProcess:ohtml:ValByName("cResposta",cResposta)
oProcess:ohtml:ValByName("cNomeC7",cNomeSC7)
oProcess:cTo := cMilQuest//"everton.forti@totvs.com.br"//

oProcess:Start()

return

Static Function MontaHtml()

Local cHTM		:=""
//Local cModHtm 	:= ""
Local cArqHTM	:= CriaTrab( NIL , .F. ) + ".htm"
Local cPasta	:= "\messenger\emp" + cEmpAnt
Local nHdl		:= Fcreate(cPasta+ "\" +cArqHTM)			//Numero do arquivo na memoria
//Local cHostWF	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link.
//Local cHostWF1	:= "http://192.168.0.60:8089"	//URL configurado no ini para WF Link.
//Local c123 		:= "'"

cHTM := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
cHTM += '<html xmlns="http://www.w3.org/1999/xhtml">'+ CRLF

cHTM += '<head>'+ CRLF

cHTM += '<title> Questionamento Pedido de Compras - '+ ALLTRIM(SM0->M0_NOMECOM)+ '</title>'+ CRLF

cHTM += '</head>' + CRLF
cHTM += '<body>' + CRLF


cHTM += '        <div class="col-md-6 mb-3"></div> ' + CRLF
cHTM += '        <img src="http://www.conasa.com/img/configuracoes/logo-2005-2019.png"  alt="...">' + CRLF
cHTM += '        </div><BR>' + CRLF
cHTM += '          Questionamento Empresa - <b>'+ ALLTRIM(SM0->M0_NOMECOM)+ ' </b><BR>' + CRLF
cHTM += '          Pedido de Compra - <b>'+ ALLTRIM(cNumPed)+  '</b><BR><BR>' + CRLF
if !empty(cTemp1)
    cHTM += '		   Histórico:  '+cTemp1+'<BR>' + CRLF
endif
cHTM += '			<BR>Questionamento deste Workflow: '+ cTemp2+'<BR>' + CRLF
cHTM += '        <!-- Form--><BR>' + CRLF
cHTM += '      <form class="was-validated" name="form1" method="post" action=""> ' + CRLF
cHTM += '		<br>' + CRLF
cHTM += '			<p>Clique no <a href="!A_LINK!">link</a> para responder.</p>' + CRLF
cHTM += '            <div class="col-md-6 mb-3">' + CRLF
cHTM += '            <input type="button"> <a href="!A_LINK!">Clique Aqui</a></button>' + CRLF
cHTM += '            </div>' + CRLF

cHTM += '       <BR><br><I><h6 align="LEFT">Mensagem enviada pelo sistema de WorkFlow da TOTVS S/A.</h6></I>'
cHTM += '        </form>' + CRLF


cHTM += '</table>' + CRLF
cHTM += '</body>' + CRLF
cHTM += '</html>' + CRLF



FWrite(nHdl,cHTM,Len(cHTM))

//Fecha LOG
FClose(nHdl)

cHTM := ""
Ms_Flush()

Return (cPasta+ "\" +cArqHTM)
