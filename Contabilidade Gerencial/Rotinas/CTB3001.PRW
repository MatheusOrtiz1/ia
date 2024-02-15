#include "protheus.ch"
#include "topConn.ch"
#include "tbiConn.ch"
#INCLUDE "restFul.ch"

#define CRLF chr(10)

/*
Programa.: CTB3001.PRW
Tipo.....: Rotina (PDF) 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 18/02/2020
Descrição: Gerar XML - Balancete e/ou DRE
Notas....: 
*/

static oAlerts  := tcAlerts():New()		//Classe customizada para controle de mensagens - tcSmart/Classes
static cTitle 	:= "Gerar XML - Balancete e/ou DRE"
static cProgram := "CTB3001"


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB3001
Função principal do programa
@author Odair Batista - TOTVS Unidade Londrina
@since 18/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
user function CTB3001()
	local aAlerts := {}
	local cAlerts := ""
	local nRow    := 0

    private cXML := ""
    
	if !input()
		return
	endIf

	oAlerts:Empty()
	
	processa({|| doPut()})
	
	aAlerts := oAlerts:GetAlerts()
	
	if len(aAlerts) > 0
		cAlerts := "<ERRORS>
		
		for nRow := 1 to len(aAlerts)
			cAlerts += "<ERROR>" + allTrim(aAlerts[nRow, 3]) + " [" + allTrim(aAlerts[nRow, 2]) + "] --> " + allTrim(aAlerts[nRow, 4]) + "</ERROR>"
		next nRow
		
		cAlerts += "</ERRORS>
		
		cXML += cAlerts
	endIf
	
	U_tcMkFile("spool", "CTB3001.xml", mv_par03, cXML)
return


//-------------------------------------------------------------------
/*/{Protheus.doc} input
Entrada de dados para seleção do relatório
@author Odair Batista - TOTVS Unidade Londrina
@since 18/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function input()
	local aParamBox  := {}
	local aRet       := {}
	local bOk        := {|| .t.}
	local aButtons   := {}
	local lCentered  := .t. 
	local nPosX      := nil
	local nPosY      := nil
	local oDlgWizard := nil
	local cLoad      := allTrim(cProgram) + ".pbx"
	local lCanSave   := .t.		
	local lUserSave  := .t.	
	local okPress    := .f.
	
	aAdd(aParamBox, {1, "Ano"        , 4         , "@E 9999", "", "", "", 035, .f.})
	aAdd(aParamBox, {1, "Mês"        , 2         , "@E 99"  , "", "", "", 020, .f.})
	aAdd(aParamBox, {1, "Caminho XML", space(200), ""       , "", "", "", 150, .f.})
	aAdd(aParamBox, {3, "Modelo", 1, {"Balancete Contábil", "Demonstrativo de Resultado", "Ambos"}, 120, "", .f.})

	okPress := paramBox(aParamBox ;		//Array: 	Array contendo as perguntas
						, cTitle ;		//Caracter:	Título da tela
						, aRet ;		//Array:	Array contendo as respostas
						, bOk ;			//Array:	Code block para validar o botão Ok
						, aButtons; 	//Array:	Array contendo definições dos botões opcionais, além dos botões de Ok e Cancel
						, lCentered ; 	//Lógico:	Indica se será centralizada a janela
						, nPosX ;		//Numérico:	Se não centralizar janela, coordenada X da janela
						, nPosY ;		//Numérico:	Se não centralizar janela, coordenada Y da janela
						, oDlgWizard ;	//Objeto: 	Objeto referente à janela ativa
						, cLoad ;		//Caracter:	Nome arquivo para gravar respostas
						, lCanSave ; 	//Lógico:	Indica se pode salvar o arquivo com respostas
						, lUserSave)	//Lógico:	Indica se salva nome do usuario no arquivo
	
	if !okPress
		return .f.
	endIf
return .t. 


//-------------------------------------------------------------------
/*/{Protheus.doc} doPut
Impressão do relatório
@author Odair Batista - TOTVS Unidade Londrina
@since 18/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function doPut()
	private isHeader := .t.
	private cXML     := ""
	private cCodMun := ""
  	private aRange  := array(2)	 

	procRegua(0)
	incProc("Aguarde! Processando solicitação...")

	cCodMun   := superGetMV("MV_UCODMUN", .f., "", cFilAnt)		
	aRange[1] := sToD(strZero(mv_par01, 4) + strZero(mv_par02, 2) + "01")		//Primeiro dia do mês/ano solicitado
	aRange[2] := lastDay(aRange[1])												//Último dia do mês/ano solicitado
	isHeader  := .t.
	
	openXML()
	
	if mv_par04 == 1 .or. mv_par04 == 3	//Balancete
		doPutBAL()
	endIf

	if mv_par04 == 2 .or. mv_par04 == 3	//DRE
		doPutDRE()
	endIf
	
	closeXML()

    if !oAlerts:HasErrors() ;
    	.and. empty(cXML)
    	 
	    oAlerts:Add("doPut" ;
	    			, "XML Processado!" ;
	    			, "I" ;
	    			, "XML Processado mas não houve retorno ou erro. Verifique!")
	endIf
return


/*/{Protheus.doc} openXML
Função para abertura do XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function openXML()
	cXML := ''
	cXML += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXML += '<root>'
return


/*/{Protheus.doc} closeXML
Função para fechamento do XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function closeXML()
	cXML += '</root>'
return


/*/{Protheus.doc} putHeader
Função para inputar dados do cabeçalho
@author Odair Batista - TOTVS Unidade Londrina
@since 11/02/2020
@version 1.0
@type function
@param cTitle, caracter, Título para o cabeçalho
/*/
static function putHeader(cTitle)
	cXML += '<Cabecalho>'
	cXML += '<TipoDocumento>' + cTitle + '</TipoDocumento>'
	cXML += '<AnoExercicio>' + strZero(year(aRange[1]), 4) + '</AnoExercicio>'
	cXML += '<MesExercicio>' + mesExtenso(month(aRange[1])) + '</MesExercicio>'
	cXML += '<Municipio>' + cCodMun + '</Municipio>'
	cXML += '<DataCriacaoXML>' + strZero(year(date()), 4) + "-" + strZero(month(date()), 2) + "-" + strZero(day(date()), 2) + '</DataCriacaoXML>'
	cXML += '</Cabecalho>'
	
	isHeader := .f.
return


/*/{Protheus.doc} doPutBAL
Função para inputar dados do balancete no XML
@author Odair Batista - TOTVS Unidade Londrina
@since 11/02/2020
@version 1.0
@type function
/*/
static function doPutBAL()
	local cArqTmp   := ""
	local cMoeda    := "01"
	local oMeter    := nil
	local oText	    := nil
	local oDlg	    := nil
	local isEnd	    := .f.
	local dSdoAnt   := (aRange[1] - 1)
	local dDataLP   := sToD(strZero(year(dSdoAnt), 4) + "0101")
	local ImpAnteLP := .f.
	local nDivide   := 1

	if isHeader
		putHeader("Balancete Contabil")
	endIf
	
	if select("cArqTmp") > 0
		cArqTmp->(dbCloseArea())
	endIf

	ctGerPlan(oMeter ;                                  //01-oMeter       = Controle da regua                                  
	          , oText ;                                 //02-oText        = Controle da regua                                  
              , oDlg ;                                  //03-oDlg         = Janela                                             
              , @isEnd ;                                //04-lEnd         = Controle da regua -> finalizar                     
              , @cArqTmp ;                              //05-cArqTmp      = Arquivo temporario                                 
              , aRange[1] ;                             //06-dDataIni     = Data Inicial de Processamento                     
              , aRange[2] ;                             //07-dDataFim     = Data Final de Processamento                        
              , "CT7" ;                                 //08-cAlias       = Alias do Arquivo                                   
              , "" ;                                    //09-cIdent       = Identificador do arquivo a ser processado          
              , "" ;                                    //10-cContaIni    = Conta Inicial                                      
              , replicate("Z", len(CT1->CT1_CONTA)) ;   //11-cContaFim    = Conta Final                                        
              , "" ;                                    //12-cCCIni       = Centro de Custo Inicial                            
              , replicate("Z", len(CTT->CTT_CUSTO)) ;   //13-cCCFim       = Centro de Custo Final                            
              , "" ;                                    //14-cItemIni     = Item Inicial                                       
              , replicate("Z", len(CTD->CTD_ITEM)) ;    //15-cItemFim     = Item Final                                         
              , "" ;                                    //16-cClvlIni     = Classe de Valor Inicial                            
              , replicate("Z", len(CTH->CTH_CLVL)) ;    //17-cClvlFim     = Classe de Valor Final                            
              , cMoeda ;                                //18-cMoeda       = Moeda                                               
              , "1" ;                                   //19-cSaldos      = Tipos de Saldo a serem processados                 
              , ctbSetOf("") ;                          //20-aSetOfBook   = Matriz de configuracao de livros                   
              , ;                                       //21-cSegmento    = Indica qual o segmento sera filtrado              
              , "" ;                                    //22-cSegIni      = Conteudo Inicial do segmento                     
              , replicate("Z", 20) ;                    //23-cSegFim      = Conteudo Final do segmento                         
              , ;                                       //24-cFiltSegm    = Filtra por Segmento                                  
              , .f. ;                                   //25-lNImpMov     = Se Imprime Entidade sem movimento                  
              , .f. ;                                   //26-lImpConta    = Se Imprime Conta                                   
              , ;                                       //27-nGrupo       = Grupo                                              
              , ;                                       //28-cHeader      = Identifica qual a Entidade Principal              
              , ImpAnteLP ;                             //29-lImpAntLP    = Se imprime lancamentos Lucros e Perdas             
              , dDataLP ;                               //30-dDataLP      = Data da ultima Apuracao de Lucros e Perdas       
              , nDivide ;                               //31-nDivide      = Divide valores por (100,1000,1000000)              
              , .f. ;                                   //32-lVlrZerado   = Grava ou nao valores zerados no arq temporario     
              , ;                                       //33-cFiltroEnt   = Entidade Gerencial que servira de filtro dentro de outra Entidade Gerencial. Ex.: Centro de Custo sendo filtrado por Item Contabil (CTH)
              , ;                                       //34-cCodFilEnt   = Codigo da Entidade Gerencial utilizada como filtro
              , ;                                       //35-cSegmentoG   = Filtra por Segmento Gerencial (CC/Item ou ClVl)    
              , ;                                       //36-cSegIniG     = Segmento Gerencial Inicial                         
              , ;                                       //37-cSegFimG     = Segmento Gerencial Final                           
              , ;                                       //38-cFiltSegmG   = Segmento Gerencial Contido em                     
              , ;                                       //39-lUsGaap      = Se e Balancete de Conversao de moeda              
              , ;                                       //40-cMoedConv    = Moeda para a qual buscara o criterio de conversao no Pl.Contas                                       
              , ;                                       //41-cConsCrit    = Criterio de conversao utilizado: 1-Diario, 2-Medio, 3-Mensal, 4-Informada, 5-Plano de Contas
              , ;                                       //42-dDataConv    = Data de Conversao                                  
              , ;                                       //43-nTaxaConv    = Taxa de Conversao                                  
              , ;                                       //44-aGeren       = Matriz que armazena os compositores do Pl. Ger. para efetuar o filtro de relatorio.              
              , ;                                       //45-lImpMov      = Nao utilizado                                      
              , ;                                       //46-lImpSint     = Se atualiza sinteticas                            
              , ;                                       //47-cFilUSU      = Filtro informado pelo usuario                     
              , ;                                       //48-lRecDesp0    = Se imprime saldo anterior do periodo anterior zerado                                             
              ,	;                              			//49-cRecDesp     = Grupo de receitas e despesas ('3456789')                     
              , dSdoAnt ;                               //50-dDtZeraRD    = Data de zeramento de receitas e despesas           
              , ;                                       //51-lImp3Ent     = Se e Balancete C.Custo / Conta / Item              
              , ;                                       //52-lImp4Ent     = Se e Balancete por CC x Cta x Item x Cl.Valor      
              , ;                                       //53-lImpEntGer   = Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)                            
              , ;                                       //54-lFiltraCC    = Se considera o filtro das perguntas para C.Custo   
              , ;                                       //55-lFiltraIt    = Se considera o filtro das perguntas para Item      
              , ;                                       //56-lFiltraCV    = Se considera o filtro das perguntas para Cl.Valor
              , cMoeda ;                                //57-cMoedaDsc    = Codigo da moeda para descricao das entidades       
              , ;                                       //58-lMovPeriodo  = Se imprime movimento do periodo anterior               
              , ;                                       //59-aSelFil      = Pode passar em branco
              , ;                                       //60-dDtCorte     = Pode passar em branco
              , ;                                       //61-lPlGerSint   = Pode passar em branco
              , .t. ;                                   //62-lConsSaldo   = Consolidar Saldo
              , ;                                       //63-lCompEnt     = Pode passar em branco
              , ;                                       //64-cArqAux      = Pode passar em branco
              , ;                                       //65-lUsaNmVis    = Pode passar em branco
              , ;                                       //66-cNomeVis     = Pode passar em branco
              , ;                                       //67-lCttSint     = Pode passar em branco
              , ;                                       //68-lTodasFil    = Pode passar em branco
              , ;                                       //69-cQuadroCTB   = Pode passar em branco
              , {} ;                                    //70-aEntidades   = Pode passar em branco
              ,)                                       //71-cCodEntidade = Pode passar em branco               

	dbSelectArea("cArqTmp")
	cArqTmp->(dbGoTop())

	do while !cArqTmp->(eof())
		//Descartar contas detalhadas
		if len(allTrim(cArqTmp->CONTA)) > 8
		 	cArqTmp->(dbSkip())
		 	loop
		endIf
		
		cXML += '<BalanceteContabil>'
		cXML += '<ContaContabil>' + allTrim(cArqTmp->CONTA) + '</ContaContabil>'
		cXML += '<DescricaoConta>' + alltrim(cArqTmp->DESCCTA) + '</DescricaoConta>'
		cXML += '<SaldoInicial>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOANT >= 0, cArqTmp->SALDOANT, (cArqTmp->SALDOANT * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoInicial>'
		cXML += '<NatInicial>' + iIf(cArqTmp->SALDOANT < 0, "D", "C") + '</NatInicial>'
		cXML += '<MovimentoCredito>' + allTrim(strTran(transform(cArqTmp->SALDOCRD, "@E 999999999999.99"), ",", ".")) + '</MovimentoCredito>'
		cXML += '<MovimentoDebito>' + allTrim(strTran(transform(cArqTmp->SALDODEB, "@E 999999999999.99"), ",", ".")) + '</MovimentoDebito>'
		cXML += '<SaldoFinal>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOATU >= 0, cArqTmp->SALDOATU, (cArqTmp->SALDOATU * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoFinal>'
		cXML += '<NatFinal>' + iIf(cArqTmp->SALDOATU < 0, "D", "C") + '</NatFinal>'
		cXML += '</BalanceteContabil>'
		
		cArqTmp->(dbSkip())
	endDo

	cArqTmp->(dbCloseArea())
return


/*/{Protheus.doc} doPutDRE
Função para inputar dados do demonstrativo de resultado (DRE) no XML
@author Odair Batista - TOTVS Unidade Londrina
@since 10/02/2020
@version 1.0
@type function
/*/
static function doPutDRE()
	local cArqTmp := ""
	local cMoeda  := "01"
	local oMeter  := nil
	local oText	  := nil
	local oDlg	  := nil
	local isEnd	  := .f.
	local dSdoAnt := (aRange[1] - 1)
	local dDataLP := sToD(strZero(year(dSdoAnt), 4) + "0101")
	local nDivide := 1
	local cDesCta := ""
	
	if isHeader
		putHeader("Demonstrativo de Resultado")
	endIf
	
	if select("cArqTmp") > 0
		cArqTmp->(dbCloseArea())
	endIf
	
	// CT2->CT2_ROTINA igual a CTBA211
	ctGerPlan(oMeter ;                                  //01-oMeter       = Controle da regua                                  
	          , oText ;                                 //02-oText        = Controle da regua                                  
              , oDlg ;                                  //03-oDlg         = Janela                                             
              , @isEnd ;                                //04-lEnd         = Controle da regua -> finalizar                     
              , @cArqTmp ;                              //05-cArqTmp      = Arquivo temporario                                 
              , aRange[1] ;                             //06-dDataIni     = Data Inicial de Processamento                     
              , aRange[2] ;                             //07-dDataFim     = Data Final de Processamento                        
              , "" ;                                    //08-cAlias       = Alias do Arquivo                                   
              , "" ;                                    //09-cIdent       = Identificador do arquivo a ser processado          
              , "" ;                                    //10-cContaIni    = Conta Inicial                                      
              , replicate("Z", len(CT1->CT1_CONTA)) ;   //11-cContaFim    = Conta Final                                        
              , "" ;                                    //12-cCCIni       = Centro de Custo Inicial                            
              , replicate("Z", len(CTT->CTT_CUSTO)) ;   //13-cCCFim       = Centro de Custo Final                            
              , "" ;                                    //14-cItemIni     = Item Inicial                                       
              , replicate("Z", len(CTD->CTD_ITEM)) ;    //15-cItemFim     = Item Final                                         
              , "" ;                                    //16-cClvlIni     = Classe de Valor Inicial                            
              , replicate("Z", len(CTH->CTH_CLVL)) ;    //17-cClvlFim     = Classe de Valor Final                            
              , cMoeda ;                                //18-cMoeda       = Moeda                                               
              , "1" ;                                   //19-cSaldos      = Tipos de Saldo a serem processados                 
              , ctbSetOf("999") ;                       //20-aSetOfBook   = Matriz de configuracao de livros                   
              , space(2) ;                              //21-cSegmento    = Indica qual o segmento sera filtrado              
              , space(20) ;                             //22-cSegIni      = Conteudo Inicial do segmento                     
              , replicate("Z", 20) ;                    //23-cSegFim      = Conteudo Final do segmento                         
              , space(30) ;                             //24-cFiltSegm    = Filtra por Segmento                                  
              , ;                                       //25-lNImpMov     = Se Imprime Entidade sem movimento                  
              , ;                                       //26-lImpConta    = Se Imprime Conta                                   
              , ;                                       //27-nGrupo       = Grupo                                              
              , ;                                       //28-cHeader      = Identifica qual a Entidade Principal              
              , .f. ;                                   //29-lImpAntLP    = Se imprime lancamentos Lucros e Perdas             
              , dDataLP ;                               //30-dDataLP      = Data da ultima Apuracao de Lucros e Perdas       
              , nDivide ;                               //31-nDivide      = Divide valores por (100,1000,1000000)              
              , .f. ;                                   //32-lVlrZerado   = Grava ou nao valores zerados no arq temporario     
              , ;                                       //33-cFiltroEnt   = Entidade Gerencial que servira de filtro dentro de outra Entidade Gerencial. Ex.: Centro de Custo sendo filtrado por Item Contabil (CTH)
              , ;                                       //34-cCodFilEnt   = Codigo da Entidade Gerencial utilizada como filtro
              , ;                                       //35-cSegmentoG   = Filtra por Segmento Gerencial (CC/Item ou ClVl)    
              , ;                                       //36-cSegIniG     = Segmento Gerencial Inicial                         
              , ;                                       //37-cSegFimG     = Segmento Gerencial Final                           
              , ;                                       //38-cFiltSegmG   = Segmento Gerencial Contido em                     
              , ;                                       //39-lUsGaap      = Se e Balancete de Conversao de moeda              
              , ;                                       //40-cMoedConv    = Moeda para a qual buscara o criterio de conversao no Pl.Contas                                       
              , ;                                       //41-cConsCrit    = Criterio de conversao utilizado: 1-Diario, 2-Medio, 3-Mensal, 4-Informada, 5-Plano de Contas
              , ;                                       //42-dDataConv    = Data de Conversao                                  
              , ;                                       //43-nTaxaConv    = Taxa de Conversao                                  
              , ;                                       //44-aGeren       = Matriz que armazena os compositores do Pl. Ger. para efetuar o filtro de relatorio.              
              , ;                                       //45-lImpMov      = Nao utilizado                                      
              , ;                                       //46-lImpSint     = Se atualiza sinteticas                            
              , ;                                       //47-cFilUSU      = Filtro informado pelo usuario                     
              , ;                                       //48-lRecDesp0    = Se imprime saldo anterior do periodo anterior zerado                                             
              ,	;                              			//49-cRecDesp     = Grupo de receitas e despesas ('3456789')                     
              , ;                               		//50-dDtZeraRD    = Data de zeramento de receitas e despesas           
              , ;                                       //51-lImp3Ent     = Se e Balancete C.Custo / Conta / Item              
              , ;                                       //52-lImp4Ent     = Se e Balancete por CC x Cta x Item x Cl.Valor      
              , ;                                       //53-lImpEntGer   = Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)                            
              , ;                                       //54-lFiltraCC    = Se considera o filtro das perguntas para C.Custo   
              , ;                                       //55-lFiltraIt    = Se considera o filtro das perguntas para Item      
              , ;                                       //56-lFiltraCV    = Se considera o filtro das perguntas para Cl.Valor
              , cMoeda ;                                //57-cMoedaDsc    = Codigo da moeda para descricao das entidades       
              , .t. ;                                   //58-lMovPeriodo  = Se imprime movimento do periodo anterior               
              , ;                                       //59-aSelFil      = Pode passar em branco
              , ;                                       //60-dDtCorte     = Pode passar em branco
              , .t. ;                                   //61-lPlGerSint   = Pode passar em branco
              , .f. ;                                   //62-lConsSaldo   = Consolidar Saldo
              , ;                                       //63-lCompEnt     = Pode passar em branco
              , ;                                       //64-cArqAux      = Pode passar em branco
              , ;                                       //65-lUsaNmVis    = Pode passar em branco
              , ;                                       //66-cNomeVis     = Pode passar em branco
              , ;                                       //67-lCttSint     = Pode passar em branco
              , ;                                       //68-lTodasFil    = Pode passar em branco
              , ;                                       //69-cQuadroCTB   = Pode passar em branco
              , ;                                       //70-aEntidades   = Pode passar em branco
              , ;                                       //71-cCodEntidade = Pode passar em branco               
              , ;
              , (aRange[1] - 1))

	dbSelectArea("cArqTmp")
	cArqTmp->(dbGoTop())

	do while !cArqTmp->(eof())
		//Indica se a entidade gerencial sera impressa/visualizada em na consulta após o processamento da visão
		if cArqTmp->VISENT == "2"
			cArqTmp->(dbSkip())
			loop
		endIf
	
		cDesCta := posicione("CTS", 2, xFilial("CTS") + "999" + cArqTmp->CONTA, "CTS_DETHCG")
		cDesCta := allTrim(cArqTmp->DESCCTA) + rTrim(cDesCta)
	
		cXML += '<BalanceteContabil>'
		cXML += '<ContaContabil>' + allTrim(cArqTmp->CONTA) + '</ContaContabil>'
		cXML += '<DescricaoConta>' + cDesCta + '</DescricaoConta>'
		cXML += '<SaldoInicial>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOANT >= 0, cArqTmp->SALDOANT, (cArqTmp->SALDOANT * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoInicial>'
		cXML += '<NatInicial>' + iIf(cArqTmp->SALDOANT < 0, "D", "C") + '</NatInicial>'
		cXML += '<MovimentoCredito>' + allTrim(strTran(transform(cArqTmp->SALDOCRD, "@E 999999999999.99"), ",", ".")) + '</MovimentoCredito>'
		cXML += '<MovimentoDebito>' + allTrim(strTran(transform(cArqTmp->SALDODEB, "@E 999999999999.99"), ",", ".")) + '</MovimentoDebito>'
		cXML += '<SaldoFinal>' + allTrim(strTran(transform(iIf(cArqTmp->SALDOATU >= 0, cArqTmp->SALDOATU, (cArqTmp->SALDOATU * -1)), "@E 999999999999.99"), ",", ".")) + '</SaldoFinal>'
		cXML += '<NatFinal>' + iIf(cArqTmp->SALDOATU < 0, "D", "C") + '</NatFinal>'
		cXML += '</BalanceteContabil>'
		
		cArqTmp->(dbSkip())
	endDo

	cArqTmp->(dbCloseArea())
return
