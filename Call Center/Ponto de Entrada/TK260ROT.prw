/*±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK260ROT   ³ Aut.  ³Diorgny	            ³ Data ³07/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Transformat prospect em Cliente   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Módulo: CALLCENTER			Rotina: Tornar Cliente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

User Function TK260ROT()
local aRotina := {}
                    
aadd( aRotina, { "Tornar Cliente"      , "U_MPROSP" , 0, 3} )

return aRotina


User Function MPROSP()
//Local nOpca := 0 
Local aParam := {}
Local cProsp:= SUS->US_COD 
Local cLoja:= SUS->US_LOJA  
//Local cSql		:= ""
//Local _cCodPg	:= ""
LOCAL MV_UA1CTB := GETMV("MV_UA1CTB")
LOCAL MV_UCTBSEQ:= GETMV("MV_UCTBSEQ")
LOCAL MV_UCTASQ1:= GETMV("MV_UCTASQ1")
LOCAL cCtbConta := ""
Local aArea := GetArea()
Local aAreaCVD := CVD->( GetArea() )
Local cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local cSvEmpAnt := cEmpAnt //Salva a Empresa Anterior
Local cSvArqTab := cArqTab //Salva os arquivos de //trabalho
Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
Local cNewAls := GetNextAlias() //Obtem novo Alias

nReg := Recno()
SUS->(dbGoTo(nReg))
                    
//adiciona codeblock a ser executado no inicio, meio e fim
aAdd( aParam, {|| U_MPROSP1() } )
aAdd( aParam, {|| U_MPROSP2() } ) //ao fim da transação


if SUS->US_STATUS == "6"     // Status não pode ser = CLIENTE
   MsgAlert("Este Prospect já se tornou cliente!","Já Existe")
   return .F.
endif

nOpc := AxInclui("SA1",,3,,"U_MPROSP1",,,,"U_MPROSP2")
If nOpc = 1
   // mudo o US_STATUS para cliente (6) e faço as amarrações de contatos com o novo cliente.
   DbselectArea("SUS")
   Posicione("SUS",1,xFilial("SUS")+cProsp+cLoja,"US_LOJA")
   RecLock("SUS",.f.)
             SUS->US_STATUS := "6"
             SUS->US_CODCLI := SA1->A1_COD
             SUS->US_LOJACLI := SA1->A1_LOJA
             SUS->US_DTCONV := dDatabase //database do sistema
   MsUnlock()   
   
   	IF MV_UA1CTB   //Define se ira criar conta contabil automaticamente ao transformar o prospect
		
		IF MV_UCTBSEQ // Cria conta contabil sequencial para estas emrpesa 01,02,03,04,06,08,09
			
			MV_UCTASQ1 := MV_UCTASQ1+1
			cCtbConta  := cavaltochar(MV_UCTASQ1)
			
			DBSELECTAREA("CT1")
			DBSETORDER(1)
			IF !DBSEEK(XFILIAL()+M->A2_CONTA)
				ACT1 := {}
				AADD(ACT1,{"CT1_FILIAL"	,	XFILIAL("CT1")		,NIL})
				AADD(ACT1,{"CT1_CONTA"	,	cCtbConta	  		,NIL})
				AADD(ACT1,{"CT1_DESC01"	,	SUS->US_NOME   		,NIL})
				AADD(ACT1,{"CT1_CLASSE"	,	"2"         		,NIL})
				AADD(ACT1,{"CT1_NORMAL" ,	"2"         		,NIL})
				AADD(ACT1,{"CT1_NTSPED" ,	"02"        		,NIL})
				AADD(ACT1,{"CT1_GRUPO"  ,   "11301001"          ,NIL})
				
				LMSERROAUTO := .F.
				LMSHELPAUTO := .T.
				
				MSEXECAUTO({|X,Y| CTBA020(X,Y)},ACT1,3)
				IF LMSERROAUTO
					MSG := "Erro ao criar a conta contabil !"+CHR(13)
					MSG += "Verificar !"
					MSGBOX(MSG,"Atencao","ERROR")
					MOSTRAERRO()
					LRET := .F.
				ELSE
					PutMV("MV_UCTASQ1",MV_UCTASQ1)
				ENDIF
				
			ENDIF
			
		ELSE
			
			DBSELECTAREA("CT1")
			DBSETORDER(1)
			IF !DBSEEK(XFILIAL()+SA1->A1_CONTA)
				ACT1 := {}
				AADD(ACT1,{"CT1_FILIAL"	,	xFILIAL("CT1")	   												    			 	,NIL})
				AADD(ACT1,{"CT1_CONTA"	,	"11201001"+IF(SUS->US_TIPO=="F",LEFT(SUS->US_CGC,9)+"001",LEFT(SUS->US_CGC,12))		,NIL})
				AADD(ACT1,{"CT1_DESC01"	,	SUS->US_NOME																		,NIL})
				AADD(ACT1,{"CT1_CLASSE"	,	"2"         																		,NIL})
				AADD(ACT1,{"CT1_NORMAL" ,	"1"         																		,NIL})
				AADD(ACT1,{"CT1_NTSPED" ,	"01"        																		,NIL})
				AADD(ACT1,{"CT1_GRUPO"  ,   "1.1.2"             																,NIL})
				LMSERROAUTO := .F.
				LMSHELPAUTO := .T.
				MSEXECAUTO({|X,Y| CTBA020(X,Y)},ACT1,3)//AQUI CRIA A CONTA NA CT1
				IF LMSERROAUTO //ENTRA SE DER ERRO NA CRIALÇAO DA CONTA
					MSG := "Erro ao criar a conta contabil !"+CHR(13)
					MSG += "Verificar !"
					MSGBOX(MSG,"Atencao","ERROR")
					MOSTRAERRO()
				ENDIF
				IF !LMSERROAUTO
					IF EmpOpenFile(cNewAls,"CVD",1,.T.,"07",@cModo)
						//...coloque aqui o seu código
						RECLOCK(cNewAls, .T.)
						//							cNewAls->CVD_FILIAL     := xFilial("CVD")   // Retorna a filial de acordo com as configurações do ERP Protheus
						&(cNewAls+"->"+"CVD_CONTA")     := "11201001"+IF(SUS->US_TIPO=="F",LEFT(SUS->US_CGC,9)+"001",LEFT(SUS->US_CGC,12))
						&(cNewAls+"->"+"CVD_ENTREF")    := "10"
						&(cNewAls+"->"+"CVD_CODPLA")    := "005"
						&(cNewAls+"->"+"CVD_CTAREF")    := "1.01.02.02.01"
						&(cNewAls+"->"+"CVD_CUSTO")  	:= ""
						&(cNewAls+"->"+"CVD_TPUTIL") 	:= "A"
						&(cNewAls+"->"+"CVD_CLASSE") 	:= "2"
						&(cNewAls+"->"+"CVD_NATCTA") 	:= "02"
						&(cNewAls+"->"+"CVD_CTASUP") 	:= "1.01.02.02"
						MSUNLOCK()     // Destrava o registro
						( cNewAls )->( dbCloseArea() )
					EndIF
						
					IF EmpOpenFile(cNewAls,"CVD",1,.T.,"27",@cModo)
						//...coloque aqui o seu código
						RECLOCK(cNewAls, .T.)
						//							cNewAls->CVD_FILIAL     := xFilial("CVD")   // Retorna a filial de acordo com as configurações do ERP Protheus
						&(cNewAls+"->"+"CVD_CONTA")     := "11201001"+IF(SUS->US_TIPO=="F",LEFT(SUS->US_CGC,9)+"001",LEFT(SUS->US_CGC,12))
						&(cNewAls+"->"+"CVD_ENTREF")    := "10"
						&(cNewAls+"->"+"CVD_CODPLA")    := "006"
						&(cNewAls+"->"+"CVD_CTAREF")    := "1.01.02.02.01"
						&(cNewAls+"->"+"CVD_CUSTO")  	:= ""
						&(cNewAls+"->"+"CVD_TPUTIL") 	:= "A"
						&(cNewAls+"->"+"CVD_CLASSE") 	:= "2"
						&(cNewAls+"->"+"CVD_NATCTA") 	:= "02"
						&(cNewAls+"->"+"CVD_CTASUP") 	:= "1.01.02.02"
						MSUNLOCK()     // Destrava o registro
						( cNewAls )->( dbCloseArea() )
					EndIF
				
					//Restaura os Dados de Entrada ( Ambiente )
					cFilAnt := cSvFilAnt
					cEmpAnt := cSvEmpAnt
					cArqTab := cSvArqTab
				
					//Restaura os ponteiros das Tabelas
					RestArea( aAreaCVD )
					RestArea( aArea )
						
				ENDIF  //!LMSERROAUTO
					
					
			ENDIF
		ENDIF
	ENDIF
   
Endif 

Return .T.

//executa antes da transação
USER Function MPROSP1()
//todos os campos que quero que retorne no cadastro
M->A1_FILIAL    := SUS->US_FILIAL
IF SUS->US_CGC!=""
	M->A1_COD  := substr(SUS->US_CGC,1,9)
	M->A1_LOJA := substr(SUS->US_CGC,10,3)
ELSE
	M->A1_COD  := ""
	M->A1_LOJA := ""
ENDIF
M->A1_NOME   	:= SUS->US_NOME
M->A1_NREDUZ 	:= SUS->US_NREDUZ 
M->A1_TIPO 		:= SUS->US_TIPO
M->A1_END 		:= SUS->US_END
M->A1_EST 		:= SUS->US_EST
M->A1_ESTADO	:= SUS->US_EST
M->A1_BAIRRO 	:= SUS->US_BAIRRO
M->A1_CEP 		:= SUS->US_CEP
M->A1_DDI 		:= SUS->US_DDI
M->A1_DDD 		:= SUS->US_DDD
M->A1_TEL 		:= SUS->US_TEL
M->A1_MUN 		:= SUS->US_MUN
M->A1_CGC 		:= SUS->US_CGC
M->A1_EMAIL		:= SUS->US_EMAIL 
M->A1_SATIV1 	:= SUS->US_SATIV
M->A1_VEND 		:= SUS->US_VEND
M->A1_OBSERV	:= SUS->US_OBS		 
M->A1_CONTA		:= "11201001"+IF(US_TIPO=="F",LEFT(US_CGC,9)+"001",LEFT(US_CGC,12))     
                             
Return .T.           

USER Function MPROSP2()

Alert("Cliente migrado com sucesso!")

Return .T.
