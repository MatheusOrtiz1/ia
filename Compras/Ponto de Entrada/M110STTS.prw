
#include "PROTHEUS.CH"  
#include "TBICONN.CH" 
#include "rwmake.ch" 
#include "TbiCode.ch"
#include "ap5mail.ch"
#define ENTER CHR(13)+CHR(10)

User Function M110STTS()
Local lAtiva      := SuperGetMV("MV_UWF120P",.F.,.F.) //Parametro para ativar Workflow do compras 
Private cNumSol   := ALLTRIM(Paramixb[1])
Private nOpt      := Paramixb[2]
Private lCopia    := Paramixb[3]

IF !lAtiva
	RETURN()
ENDIF

Do case
    case nOpt == 1     
        //msgalert("Solicitação "+alltrim(cNumSol)+" incluída com sucesso!") 
        U_wFsolIni() //INICIA PROCESSO
    case nOpt == 2     
       // msgalert("Solicitação "+alltrim(cNumSol)+" alterada com sucesso!")     
        U_wFsolIni() //INICIA PROCESSO
    case nOpt == 3     
        //msgalert("Solicitação "+alltrim(cNumSol)+" excluída com sucesso!")
Endcase
     
Return Nil


//-------------------------------------------------------------------
//wFiniciar - Função para envio do Workflow
//-------------------------------------------------------------------  
User Function wFsolIni()
	Local oProcess 	:= Nil							//Objeto da classe TWFProcess.
	Local cMailId 	:= ""							//ID do processo gerado. 
	//Local cHostWF	:= "http://192.168.0.60:8089"	//URL configurado no ini para WF Link. 
	Local cHostWFB	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link. 
	Local cTo 		:= "everton.forti@totvs.com.br;" 	//Destinatário de email.    
	Local xChavSCR
	Local nTotal	:= 0 
	Local cObs		:= ""
	Local lDEBUG	:= .F.
	Local cDest		:= ""	
	Local cAssunto  := "Workflo Pedido de Compras"	

	IF lDEBUG
        cNumSol := "000651"
        PREPARE ENVIRONMENT EMPRESA "44" FILIAL "01"    
	ENDIF

	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
	
	dBselectArea('SC1')//PEDIDO COMPRA
	dbSetOrder(1)
	dbSeek(xFilial("SC1")+cNumSol)
	//000754                                            '
	xChavSCR:= xFilial("SCR")+"IP"+cNumSol+SPACE(44)+"02"
	
	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
		WHILE SCR->(!EOF()) .AND. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == xChavSCR
			cTo += UsrRetMail(SCR->CR_USER)+";"
			cDest += UsrRetMail(SCR->CR_USER)+";"
		SCR->(DBSKIP())
		ENDDO
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif

	dBselectArea('SCR')//ALCADAS PED.COMRA
	dbSetOrder(1)
	dbSeek(xChavSCR)
                      
	dBselectArea('SA2')//FORNECEDORES
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC1->C1_FORNECE)
	
	//dbSelectArea('SE4')//COND.PAGAMENTO
	//dbSetOrder(1)
	//dbSeek(xFilial('SE4')+SC1->C1_COND)
	
	dbSelectArea('SAK')//APROVADORES
	dbSetOrder(1)
	dbSeek(xFilial('SAK')+SCR->CR_APROV)

	cAssunto  := "Workflow Compras "+Alltrim(SM0->M0_NOME) + " - "+ alltrim(SM0->M0_FILIAL) +" - Pedido:  "+Substr(cNumSol,3,6)+"-"+SA2->A2_NREDUZ

	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o código e nome do processo.  
	//-------------------------------------------------------------------  
	oProcess := TWFProcess():New("000001", cAssunto)

	//-------------------------------------------------------------------
	// Criamos a tafefa principal que será respondida pelo usuário.  
	//-------------------------------------------------------------------  
	oProcess:NewTask("FORMULARIO", "\Workflow\WF_FORMSOL.html")

	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//-------------------------------------------------------------------  	   
	oProcess:oHtml:ValByName("TEXT_TIME"	, Time() )
	oProcess:oHtml:ValByName("EMPRESA"		, SM0->M0_NOMECOM )
	oProcess:oHtml:ValByName("PEDIDO"		, SC1->C1_NUM )
	oProcess:oHtml:ValByName("USUARIO"		, SC1->C1_USER )
	oProcess:oHtml:ValByName("EMISSAO"		, SC1->C1_EMISSAO )
	oProcess:oHtml:ValByName("FORNECEDOR"	, SC1->C1_FORNECE )	                           
	oProcess:oHtml:ValByName("lb_nome"		, SA2->A2_NOME )
	//oProcess:oHtml:ValByName("lb_cond"		, SE4->E4_DESCRI )
	oProcess:oHtml:ValByName("SCRAPRV"		, SCR->CR_APROV )
	oProcess:oHtml:ValByName("SCRNIVEL"		, SCR->CR_NIVEL )
	oProcess:oHtml:ValByName("CDEST"		, cDest )

	//dBselectArea('SC1')
	//dbSetOrder(1)
	//dbSeek(cNumSol)
	
	While !Eof() .and. SC1->C1_FILIAL+SC1->C1_NUM = xFilial("SC1")+cNumSol
			
		AAdd( (oProcess:oHtml:ValByName( "produto.item" ))		,SC1->C1_ITEM )
		AAdd( (oProcess:oHtml:ValByName( "produto.codigo" ))	,SC1->C1_PRODUTO )
		AAdd( (oProcess:oHtml:ValByName( "produto.descricao" ))	,SC1->C1_DESCRI )
		AAdd( (oProcess:oHtml:ValByName( "produto.quant" ))		,TRANSFORM( SC1->C1_QUANT,'@E 99,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.unid" ))		,SC1->C1_UM )
		AAdd( (oProcess:oHtml:ValByName( "produto.preco" ))		,TRANSFORM( SC1->C1_PRECO,'@E 9,999,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.total" ))		,TRANSFORM( SC1->C1_TOTAL,'@E 9,999,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.cc" ))		,SC1->C1_CC )
		AAdd( (oProcess:oHtml:ValByName( "produto.cc" ))		,SC1->C1_CC )	
		AAdd( (oProcess:oHtml:ValByName( "produto.co" ))		,SC1->C1_CO )
		AAdd( (oProcess:oHtml:ValByName( "produto.areas" ))		,SC1->C1_ITEMCTA )		
		AAdd( (oProcess:oHtml:ValByName( "produto.ungestao" ))	,SC1->C1_CLVL )		
		WFSalvaID('SC1','C1_WFID',oProcess:fProcessID)
		
		IF !EMPTY(SC1->C1_OBS)
		cObs   += SC1->C1_ITEM+" - "+SC1->C1_OBS + " | "
		ENDIF
		
		nTotal += SC1->C1_TOTAL
	dbSkip()
	Enddo
		oProcess:oHtml:ValByName( "lb_aplic", cObs )	
		oProcess:oHtml:ValByName( "nTotal" ,TRANSFORM(nTotal,'@E 9,999,999.99' ) )

	//-------------------------------------------------------------------
	// Informamos em qual diretório será gerado o formulário.  
	//-------------------------------------------------------------------  	 
	oProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	oProcess:bTimeOut 	:= {{"u_WFCOMOUT(2)", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	oProcess:bReturn 	:= "u_WFCOMRET()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	cMailID := oProcess:Start()     

	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 

	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	oProcess:NewTask("LINK", "\workflow\WF_LINKSOL.html")
	
	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  

	//------------------------------------------------------------------- 
	//oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")  
	oProcess:ohtml:ValByName("B_LINK", cHostWFB + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")
	
	//-------------------------------------------------------------------
	// Informamos o destinatário do email contendo o link.  
	//------------------------------------------------------------------- 	
	//cTo 		+= "everton.forti@totvs.com.br;"d
	oProcess:cTo 		:= cTo   
	//oProcess:CCC		:= "diorgny@conasa.com;"  
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	oProcess:cSubject	:= cAssunto

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//------------------------------------------------------------------- 	
	oProcess:Start()   
	 
	IF lDEBUG
	    RESET ENVIRONMENT   
	ENDIF                                                     		
Return    

//-------------------------------------------------------------------
/*/WFSOLRET    
Função executada no retorno do processo. 
/*/
//-------------------------------------------------------------------       
User Function WFSOLRET( poProcess )  
   	Local cTime 	:= ""
	Local cProcesso := ""  
	Local cTarefa	:= ""  
	Local cMailID	:= ""
	Local xChavSCR	:= ""
	Local cNumSC1	:= ""
	Local cUsrSC1	:= ""
	Local cMotivo	:= ""
	Local cAprov	:= ""
	Local cScrAp	:= ""	
	Local cNivel	:= ""	

	//-------------------------------------------------------------------
	// Recuperamos a hora do processo utilizando o método RetByName.
	//------------------------------------------------------------------- 		
	cTime 		:= poProcess:oHtml:RetByName('TEXT_TIME') 
	cNumSC1 	:= poProcess:oHtml:RetByName('PEDIDO')  
	cUsrSC1 	:= poProcess:oHtml:RetByName('USUARIO')  
	cMotivo 	:= poProcess:oHtml:RetByName('lbmotivo')    
	cAprov		:= poProcess:oHtml:RetByName('RBAPROVA')
	cScrAp		:= poProcess:oHtml:RetByName('SCRAPRV')
	cNivel		:= poProcess:oHtml:RetByName('SCRNIVEL')
	     	                                                 

	If valtype(cMotivo)<>"C".OR.cMotivo=Nil
		cMotivo := " "
	EndIf	     	

	dBselectArea('SC1')
	dbSetOrder(1)
	dbSeek(xFilial("SC1")+cNumSC1)
	
	xChavSCR:= xFilial("SCR")+"PC"+SC1->C1_NUM+SPACE(44)+cNivel
	                                               
	dBselectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC1->C1_FORNECE)

	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif
	CONOUT(SCR->CR_NUM)
   
	While SCR->(!Eof()) .and. SCR->CR_FILIAL+"PC"+SCR->CR_NUM+SCR->CR_NIVEL = xChavSCR

	conout(cAprov)

		IF cAprov == "Sim" 
	 		conout('Aprova Pedido')	
					If RecLock("SCR",.f.)
					SCR->CR_DataLib := dDataBase
					SCR->CR_STATUS  := "05"
					SCR->CR_WF      := "S"
					SCR->CR_USERLIB := cScrAp
					SCR->CR_LIBAPRO := cScrAp
					SCR->CR_TIPOLIM := "D"
					MsUnLock()
					flag := "S"
					Endif
		 ELSEIF cAprov == "Nao"
	 		conout('Bloqueio de Pedido')
					If RecLock("SCR",.f.)
					SCR->CR_DataLib := dDataBase
					SCR->CR_OBS     := SUBSTR(cMotivo,1,60)
					SCR->CR_USERLIB := cScrAp
					SCR->CR_STATUS  := "04"
					SCR->CR_WF      := "S"
					SCR->CR_TIPOLIM := "D"
					MsUnLock()
					flag := "N"	 
					Endif
		 ENDIF			
    SCR->(dbSkip())
	Enddo   
	conout("SOMA1_NIVEL")
	//VERIFICA SE EXISTE MAIS NIVEIS A SER REENVIADO
	cNivel := SOMA1(alltrim(cNivel))
	cONOUT(cNivel)
	xChavSCR:= xFilial("SCR")+"PC"+SC1->C1_NUM+SPACE(44)+cNivel

	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR) .AND. flag == "S"
		//REENVIA PRÓXIMO NIVEL
		NEXTNIVEL(poProcess:oHtml,cNivel,xChavSCR,cNumSC1)
	ELSE
			//LIBERA PEDIDO DE COMPRA SC1
			while SC1->(!EOF()) .and. SC1->C1_NUM == cNumSC1
				IF cAprov == "Sim" 
						IF RecLock("SC1",.f.)
							SC1->C1_CONAPRO := "L"
						MsUnLock()
						ENDIF
						CONOUT("LIBERA PEDIDO DE COMPRA SC1")
				ELSEIF cAprov == "Nao" 
						IF RecLock("SC1",.f.)
							SC1->C1_CONAPRO := "R"
						MsUnLock()
						ENDIF
						CONOUT("BLOQUEIA PEDIDO DE COMPRA SC1")
				ENDIF
			SC1->(dbSkip())
			Enddo                
		
	ENDIF

	//	AvisaComprador(cNumSC1,flag,codfor,SA2->A2_NREDUZ,motivo,cUsrSC1)
	ConOut("--------------------A v i s a    C o m p r a d o r -------------------")
			
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
	Conout('Retorno do processo gerado às ' + cTime + " número " + cProcesso + ' ' + poProcess:oHtml:RetByName("WFMAILID") + ' tarefa ' + cTarefa + ' executado com sucesso!')
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} WFSOLOUT    
Função executada no timeout do processo. 
/*/
//-------------------------------------------------------------------
User Function WFSOLOUT( poProcess )  
	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------               
	Conout('Timeout do processo' + poProcess:FProcessID)  
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} _WFPE008    
Permite customizar a mensagem de processamento do WF por link. 
/*/
//-------------------------------------------------------------------
User Function _WFPE008()
	Local cHTML 		:= ""
	Local plSuccess		:= ParamIXB[1] 
	Local pcMessage  	:= ParamIXB[2]	
	Local pcProcessID  	:= ParamIXB[3]
	
	If ( plSuccess ) 
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para sucesso no processamento. 
		//------------------------------------------------------------------- 
    	cHTML += 'Resposta '+pcProcessID+' enviada ao servidor.!'
    	cHTML += '<br>'                                
       	cHTML += 'Processamento executado com sucesso!'
       	cHTML += '<br>'                                
    	cHTML += pcMessage
	Else       
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para falha no processamento. 
		//------------------------------------------------------------------- 
    	cHTML += 'Resposta '+pcProcessID+' NÃO enviada ao servidor.!'
    	cHTML += '<br>'    
		cHTML += 'Falha no processamento!'
    	cHTML += '<br>'
    	cHTML += pcMessage
	EndIf
Return cHTML

//Envia e-mail para o comprador avisando da liberação do pedido.
Static Function AvisaComprador(nped,flag,codfor,nomefor,motivo,cUsrSC1)

Local oProcess
Local oHtml
conout("AvisaComprador")
oProcess := TWFProcess():New( "AVISO", "AVISO COMPRADOR" )

If flag == "S"
	oProcess:NewTask("Pedido Liberado" , "\WORKFLOW\PEDLIBERADO.HTM" )
	oProcess:cSubject := "Pedido Liberado n°. "+nped
EndIf
If flag == "N"
	oProcess:NewTask("Pedido Bloqueado" , "\WORKFLOW\PEDBLOQ.HTM" )
	oProcess:cSubject := "Pedido Bloqueado n°. "+nped
EndIf
conout("Aprovado"+flag)

oHTML := oProcess:oHTML
oHtml:ValByName( "pedido" , nped )
oHtml:ValByName( "codfor", codfor)
oHtml:ValByName( "fornecedor", nomefor)
If flag == "N"
	oHtml:ValByName( "motivo", motivo)
EndIF

	oProcess:cTo := UsrRetMail(cUsrSC1)         // Destinatario do Email do comprador
	//oProcess:cTo := "everton.forti@totvs.com.br;"//diorgny@conasa.com"          // Destinatario do Email do comprador

//	oProcess:cTo := alltrim(GetMv("MV_UWFMAIL"))
oProcess:Start()
conout("Disparado")
Return

//U_NEXTNIVEL(0,"2 ","02PC000131"+SPACE(44)+"1 ","000131")
STATIC FUNCTION NEXTNIVEL(poProcess,cNivel,xChavSCR,cNumSC1)

//-------------------------------------------------------------------xFilial("SCR")+"PC"+SC1->C1_NUM+SPACE(44)+"1 "
//NEXTNIVEL - Função para envio do Workflow próximo nível
//-------------------------------------------------------------------  
	Local cMailId 	:= ""							//ID do processo gerado. 
	Local cHostWF	:= "http://192.168.0.60:8089"	//URL configurado no ini para WF Link. 
	Local cHostWFB	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link. 
	Local cTo 		:= "everton.forti@totvs.com.br;" 	//Destinatário de email.    
	Local nTotal	:= 0 
	Local cObs		:= ""
	Local lDEBUG	:= .F.
	Local cDest		:= ""
	Local cAssunto  := "Workflo Pedido de Compras"	

	CONOUT("NEXTNIVEL")
	//conout(cNivel)
	conout(xChavSCR)
	conout(cNumSC1)
	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
	
	dBselectArea('SC1')//PEDIDO COMPRA
	dbSetOrder(1)
	dbSeek(xFilial("SC1")+cNumSC1)
	
	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
		WHILE SCR->(!EOF()) .AND. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == xChavSCR
			//cTo += UsrRetMail(SCR->CR_USER)+";"
			//cDest += UsrRetMail(SCR->CR_USER)+";"
		SCR->(DBSKIP())
		ENDDO
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif

	dBselectArea('SCR')//ALCADAS PED.COMRA
	dbSetOrder(1)
	dbSeek(xChavSCR)
                      
	dBselectArea('SA2')//FORNECEDORES
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC1->C1_FORNECE)
	
	//dbSelectArea('SE4')//COND.PAGAMENTO
	//dbSetOrder(1)
	//dbSeek(xFilial('SE4')+SC1->C1_COND)
	
	dbSelectArea('SAK')//APROVADORES
	dbSetOrder(1)
	dbSeek(xFilial('SAK')+SCR->CR_APROV)

	cAssunto  := "Workflow Compras "+Alltrim(SM0->M0_NOME) + " - "+ alltrim(SM0->M0_FILIAL) +" - Pedido:  "+Substr(cNumSC1,3,6)+"-"+SA2->A2_NREDUZ
	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o código e nome do processo.  
	//-------------------------------------------------------------------  
	poProcess := TWFProcess():New("000001", cAssunto)

	//-------------------------------------------------------------------
	// Criamos a tafefa principal que será respondida pelo usuário.  
	//-------------------------------------------------------------------  
	poProcess:NewTask("FORMULARIO", "\Workflow\WF_FORMCOM.html")

	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//-------------------------------------------------------------------  	   
	poProcess:oHtml:ValByName("TEXT_TIME"	, Time() )
	poProcess:oHtml:ValByName("EMPRESA"		, SM0->M0_NOMECOM )
	poProcess:oHtml:ValByName("PEDIDO"		, SC1->C1_NUM )
	poProcess:oHtml:ValByName("USUARIO"		, SC1->C1_USER )
	poProcess:oHtml:ValByName("EMISSAO"		, SC1->C1_EMISSAO )
	poProcess:oHtml:ValByName("FORNECEDOR"	, SC1->C1_FORNECE )	                           
	poProcess:oHtml:ValByName("lb_nome"		, SA2->A2_NOME )
	//poProcess:oHtml:ValByName("lb_cond"		, SE4->E4_DESCRI )
	poProcess:oHtml:ValByName("SCRAPRV"		, SCR->CR_APROV )
	poProcess:oHtml:ValByName("SCRNIVEL"	, SCR->CR_NIVEL )
	poProcess:oHtml:ValByName("CDEST"		, cDest )

	dBselectArea('SC1')
	dbSetOrder(1)
	dbSeek(xFilial("SC1")+cNumSC1)
	
	While !Eof() .and. SC1->C1_NUM = cNumSC1
			
		AAdd( (poProcess:oHtml:ValByName( "produto.item" ))			,SC1->C1_ITEM )
		AAdd( (poProcess:oHtml:ValByName( "produto.codigo" ))		,SC1->C1_PRODUTO )
		AAdd( (poProcess:oHtml:ValByName( "produto.descricao" ))	,SC1->C1_DESCRI )
		AAdd( (poProcess:oHtml:ValByName( "produto.quant" ))		,TRANSFORM( SC1->C1_QUANT,'@E 99,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.unid" ))			,SC1->C1_UM )
		AAdd( (poProcess:oHtml:ValByName( "produto.preco" ))		,TRANSFORM( SC1->C1_PRECO,'@E 9,999,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.total" ))		,TRANSFORM( SC1->C1_TOTAL,'@E 9,999,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.cc" ))			,SC1->C1_CC )
		AAdd( (poProcess:oHtml:ValByName( "produto.cc" ))			,SC1->C1_CC )	
		AAdd( (poProcess:oHtml:ValByName( "produto.co" ))			,SC1->C1_CO )
		AAdd( (poProcess:oHtml:ValByName( "produto.areas" ))		,SC1->C1_ITEMCTA )		
		AAdd( (poProcess:oHtml:ValByName( "produto.ungestao" ))		,SC1->C1_CLVL )		
		WFSalvaID('SC1','C1_WFID',poProcess:fProcessID)
		cObs   += SC1->C1_ITEM+" - "+SC1->C1_OBS + " | "
		nTotal += SC1->C1_TOTAL
	dbSkip() 
	Enddo
		poProcess:oHtml:ValByName( "lb_aplic", cObs )	
		poProcess:oHtml:ValByName( "nTotal" ,TRANSFORM(nTotal,'@E 9,999,999.99' ) )

	//-------------------------------------------------------------------
	// Informamos em qual diretório será gerado o formulário.  
	//-------------------------------------------------------------------  	 
	poProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	poProcess:bTimeOut 	:= {{"u_WFCOMOUT(2)", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	poProcess:bReturn 	:= "u_WFCOMRET()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	cMailID := poProcess:Start()     

	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 

	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	poProcess:NewTask("LINK", "\workflow\WF_LINKCOM.html")
	
	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//------------------------------------------------------------------- 
	poProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")  
	poProcess:ohtml:ValByName("B_LINK", cHostWFB + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")
	
	//-------------------------------------------------------------------
	// Informamos o destinatário do email contendo o link.  
	//------------------------------------------------------------------- 
	poProcess:cTo 		:= cTo   
	//poProcess:CCC		:= "everton.forti@totvs.com.br;diorgny@conasa.com;"   
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	poProcess:cSubject	:= cAssunto

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//------------------------------------------------------------------- 	
	poProcess:Start()   

	IF lDEBUG
	RESET ENVIRONMENT
	ENDIF                                           		



RETURN()
