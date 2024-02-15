#include "PROTHEUS.ch"
#include "RESTFUL.ch" 
#include "parmtype.ch"
#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"
//+-------+----------------+------------------------------------------------------------------------------------------------------------+
//| Autor | Adriano Guedes  | Data :20/08/2023                                                                            
//+-------+--------+-------+------------------------------------------------------------------------------------------------------------+
//| Empresa        |                                                                                                     
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Arquivo Fonte  | WsGetCtr                                                                                                  
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Funcao:        | Integracao com portal SUSE - Para Coanasa                                                                                                                   
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Parametros      |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Objetivo        |                                                                                                                    
//|                |  

User Function WsGetCtr()

Local cJson := ""
local oJson  := JsonObject():New()
Local nX
Local nC
Local aCtr   := {} // Array co os contratos
Local cLink  := GETMV( "CN_WEBSUSE" )
Local cEndPt := GETMV("CN_EPSUSE")
Local cNaturez := ""

Private oRest := FwRest():New(cLink)  // "https://cloud213.programarte.com.br"
Private aHeader   := {} 
Private cLog      := ""
Private cErrLg    := ""
Private cMailLog  := ""
Private cFilCtr

Aadd(aHeader, "Content-Type: application/json")
Aadd(aHeader, "token: UYt4ibBY6zdCJZ3oYsGM9LmnIicm777fiEUJe/tznXM=") // UYt4ibBY6zdCJZ3oYsGM9C5OIcsiMzEYhBjniNpzSt8=

// Monta o Json para envio do GET ao S-Use

//----------------------------------------

// Conecta com a API do S-Use
oRest:SetPath(cEndPt)   // "/SuseToolsBatch/relatorioWebService/CLI0000000171"

// faz envio para conexao com S-Use via GET

	If oRest:Get(aHeader)
		ConOut("GET", oRest:GetResult())
		cJson := oRest:cResult
		oJson:FromJson(cJson)
		aNames := oJson:getNames()  
		
		For nX := 1 to Len(aNames)  
            If Alltrim(aNames[nX]) == 'linhas'  // De acordo coma documentação do Json entre Conasa e S-Use a Linhas esta os dados do contrato
			   aCtr := oJson[aNames[nX]] // gera o Json dos contratos
			EndIf 
		Next nX	

		// faz a leitura do Json dos contratos recebidos
		If Len(aCtr) > 0  
		    For nC := 1 to Len(aCtr)
					// Numero do contrato
					cNumCtr    := aCtr[nC]["numeroDoContrato"] // CN9_NUMERO
					// data de inciao da vigencia
					dDtini     := CtoD(Substr(aCtr[nC]["inicioDaVigencia"],1,10)) // CN9_DTINIC
				DbSelectArea("CN9")
				DbSetOrder(1)
				If !CN9->(Dbseek(xFilial("CN9")+cNumCtr)).AND. dDtini >= CtoD('01/01/1980')
					
					// Quantidade de dias do contrato
					If Valtype(aCtr[nC]["prazoEmDiasCorridos"]) == "U"
						nDias := 0
					Else
						nDias := Val(aCtr[nC]["prazoEmDiasCorridos"]) // CN9_VIGE
					EndIf
					// Natureza Financeira
					If Valtype(aCtr[nC]["naturezaFinanceira"]) == "U"
					 cNaturez := ""
					  cErrLg += "Contrato -> "+cNumCtr +": Erro NATUREZA " +CRLF
					  //cMailLog +=
					Else 
                      cNaturez   := aCtr[nC]["naturezaFinanceira"] // CN9_NATURE
					    DbSelectArea("SED")
					    DbSetOrder(1)
					    If !SED->(DbSeek(xFilial("SED")+Alltrim(cNaturez)))
                        	cErrLg += "Contrato -> "+cNumCtr +": Erro NATUREZA INVALIDA" +CRLF
							//cMailLog +=
						EndIf
					EndIf	
					cFilCtr    := aCtr[nC]["CNPJContratante"]
						// faz o tratamento da string CNPJ/CPF filil responsavel	
							cFilCtr  := strtran(cFilCtr,".","")
							cFilCtr  := strtran(cFilCtr,"/","")
							cFilCtr  := strtran(cFilCtr,"-","")
							cFilCtr  := Alltrim(cFilCtr)
					    
						
						If !Empty(alltrim(cFilCtr))
							If cFilCtr == "44067725000172"    // CNPJ da Filial 01
								cFilCtr := "01"
							EndIf 

							If cFilCtr == "44067725000253"    // CNPJ da Filial 02
								cFilCtr := "02"
							EndIf
						Endif
					
					// Busca do Fornecedor pelo CPF ou CNPJ
					If Valtype(aCtr[nC]["cnpj"]) == "U"
						cFornec = ""
					Else
					cFornec   := aCtr[nC]["cnpj"]   // CNC_CODIGO E CNA_FORNEC
						// faz o tratamento da string CNPJ/CPF	
							cFornec  := strtran(cFornec,".","")
							cFornec  := strtran(cFornec,"/","")
							cFornec  := strtran(cFornec,"-","")
							cFornec  := Alltrim(cFornec)
					EndIf
					// Descricao e observacao do contrato
					If Valtype(aCtr[nC]["descricao"]) == "C"
					 cDescri    := aCtr[nC]["descricao"]    // CN9_OBJCTO   
					Else
					 cDescri    := " "
					EndIf	
					
					If Valtype(aCtr[nC]["descricao"]) == "C"
					 cObs       := aCtr[nC]["observacoes"]  // CN9_OBJCTO  concatenar
					Else 
					 cObs := " " 
					EndIf
					// E-mail do usuario responsanvel
					cMailGes   := aCtr[nC]["AIF00000000551"] // CN9_GESTC
					// Se existe a retenção
					cRetem     := UPPER(Substr(Alltrim(aCtr[nC]["haRetencaoDeCaucao"]),1,1)) // CN9_FLGCAU  S = 1  E N = 2
					// faz tratamento da data de Porposta
					If Valtype(aCtr[nC]["dataDaPropostaAte"]) == "U"
						dPropost   := CtoD("  /  /    ")
					Else
						dPropost   := CtoD(Substr(aCtr[nC]["dataDaPropostaAte"],1,10)) // CN9_DTPROP
					EndIf	
					// faz Tratamento da data de assinatura
					If Valtype(aCtr[nC]["dataDeAssinatura"]) == "U"	
						dAssin     := CtoD("  /  /    ")
					Else  
						dAssin     := CtoD(Substr(aCtr[nC]["dataDeAssinatura"],1,10)) // CN9_ASSINA
					Endif
					// Valor do contrato
					// Tratamento do valor
					nValor     := StrTran(Alltrim(aCtr[nC]["valorDoContrato"]),".","")  // retira pontos
					nValor     := StrTran(nValor,",",".")  // muda separador de decimais para "."
					nValor     := Val(nValor) // CNA_VLTOT  ( SOMENTE DEPOIS DE ESCOLHER FORNECEDOR E PLANILHA)
					
						
				// GERA GRAVAÇÃO DO CONTRATO
				U_CN300AUT(cNumCtr,dDtini,nDias,cNaturez,cFornec,cDescri,cObs,cMailGes,cRetem,dPropost,dAssin,nValor)
				
		        EndIf
			Next   
		EndIf
          
	Else
		ConOut("GET", oRest:GetLastError())
	EndIf
 

Alert(cLog)
If !Empty(cErrLg)
    Alert(cErrLg)
	// Envia email log -> cMailLog
EndIf
// Apos o retorno do processo POST, grava os dados na Tabela de controle

//---------------------------------------------------------------------

Return()

// funcao de inclusao de contrato

User Function CN300AUT(cNumCtr,dDtini,nDias,cNaturez,cFornec,cDescri,cObs,cMailGes,cRetem,dPropost,dAssin,nValor)

Local cFornCtr    := ""
Local cLjForn     := ""
Local oModel := FWLoadModel("CNTA300") //Carrega o modelo

DbSelectArea("SA2")
DbSetOrder(3)
If SA2->(DbSeek(xfilial("SA2")+cFornec)) 
    cFornCtr := SA2->A2_COD
	cLjForn  := SA2->A2_LOJA
    // Se a Natureza estiver vazia retorna, LOG Ja foi gravado com erro na Natureza antes de chamar esta função
	If Empty(cNaturez)
	   Return
	EndIf
Else
	cErrLg += "Contrato -> "+cNumCtr +": CNPJ FORECEDOR NAO CADASTRADO " +CRLF
	//cMailLog +=
	Return
EndIf

	oModel:SetOperation(MODEL_OPERATION_INSERT) // Seta operação de inclusão

	oModel:Activate() // Ativa o Modelo

	//Cabeçalho do contrato
	oModel:SetValue( 'CN9MASTER' , 'CN9_FILIAL' , "01" )
	oModel:SetValue( 'CN9MASTER' , 'CN9_DTINIC' , dDtini )
	oModel:SetValue( 'CN9MASTER' , 'CN9_NUMERO' , cNumCtr )
	oModel:SetValue( 'CN9MASTER' , 'CN9_UNVIGE' , '1' )
	oModel:SetValue( 'CN9MASTER' , 'CN9_VIGE' , nDias )
	oModel:SetValue( 'CN9MASTER' , 'CN9_MOEDA' , 1 )
	oModel:SetValue( 'CN9MASTER' , 'CN9_CONDPG' , '01' )
	oModel:SetValue( 'CN9MASTER' , 'CN9_TPCTO' , '029' ) // *** coloar parametros SEM PLANILHA E CRONOGRAMA
	If cRetem == 'S' 
	oModel:SetValue( 'CN9MASTER' , 'CN9_FLGCAU' , '1' )
	oModel:SetValue( 'CN9MASTER' , 'CN9_TPCAUC' , '2' )
	oModel:SetValue( 'CN9MASTER' , 'CN9_MINCAU' , 5 )  // PERCENTUAL DE RETENÇÃO QUANDO E SOMENTE SE RETENCAO FOR IOGUAL A S
    EndIf
	oModel:SetValue( 'CN9MASTER' , 'CN9_OBJCTO' , "  INT. S-USE" )
	oModel:SetValue( 'CN9MASTER' , 'CN9_DTPROP' , dPropost )
	oModel:SetValue( 'CN9MASTER' , 'CN9_ASSINA' , dAssin )
    oModel:SetValue( 'CN9MASTER' , 'CN9_NATURE' , cNaturez )  

	//Cliente/Fornecedor do Contrato
	oModel:SetValue( 'CNCDETAIL' , 'CNC_CODIGO' , cFornCtr )
	oModel:SetValue( 'CNCDETAIL' , 'CNC_LOJA'   , cLjForn )
	//Planilhas do Contrato
	oModel:LoadValue( 'CNADETAIL' , 'CNA_CONTRA' , cNumCtr )
	oModel:SetValue( 'CNADETAIL'  , 'CNA_NUMERO' , '000001' )
	oModel:SetValue( 'CNADETAIL'  , 'CNA_FORNEC' , cFornCtr  )
	oModel:SetValue( 'CNADETAIL'  , 'CNA_LJFORN' , cLjForn  )
	oModel:SetValue( 'CNADETAIL'  , 'CNA_TIPPLA' , '024' )
	oModel:SetValue( 'CNADETAIL'  , 'CNA_VLTOT'  , nValor )
				
	//	CN300PrCF(.F.)
		//Validação e Gravação do Modelo
		If oModel:VldData()
    	   oModel:CommitData()
		   cLog += "Contrato -> "+cNumCtr + CRLF
		Else
			cErrLg += "Falha na gravação do Contrato, verificar Natureza ou condicao de pagamento -> "+cNumCtr + CRLF
		    // cMailLog +=
		EndIf

Return
