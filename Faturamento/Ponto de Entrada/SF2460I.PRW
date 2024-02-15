#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÍ»ÄÄÄÄÄ
ÄÄÄÄÄÂÄPrograma    F2460I ÄÄÄAutor ÄÄÄEVERTON FORTI ÄÄÄ Data ÄÄÄ 07/05/15       ÄÄÄÄÄ
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÍ¹ÄÄÄÄÄ
ÄÄÄÄÄÂÄDesc.    PONTO DE ENTRADA APOS A GRAVACO DO PEDIDO\NOTA SAIDA O          ÄÄÄÄÄ
ÄÄÄÄÄÂÄ    ISTEMA IRA GRAVAR OS CAMPOS ESPECIFICOS NA SE1                       ÄÄÄÄÄ
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÍ¹ÄÄÄÄ
*/
user function SF2460I()

PROCESSA({|| CONFIRMA()})

// Função responsável por atualizar as cargas durante o faturamento dos pedidos 
UpdCarga()

RETURN

Static Function CONFIRMA()

Local cForISS := GETMV('MV_MUNIC')
local Z
local cCLVL := "" //Incluido _CLVL/_ITEM
local cITEM := "" //Incluido _CLVL/_ITEM
LOCAL AAREA := GETAREA()
LOCAL AAREA_SD2 := SD2->(GETAREA())
LOCAL AAREA_SC5 := SC5->(GETAREA())
LOCAL AAREA_SC6 := SC6->(GETAREA())
LOCAL AAREA_SE1 := SE1->(GETAREA())
LOCAL AAREA_SE2 := SE2->(GETAREA())
PRIVATE _z23Id

/*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
ÄÄÄÄÄPOSICIONA TITULO PEDIDO DE VENDA ÄÄÄÄÄ
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ*/
dbselectarea("SC5")
ordsc5:=indexord()
recsc5:=recno()
dbsetorder(1)
dbseek(xfilial()+SD2->D2_PEDIDO)

_z23Id     := SC5->C5_UGARANT
_cCusto    := SC5->C5_UCCUSTO
_cNaturez  := SC5->C5_NATUREZ
_cHist     := SUBSTR(SC5->C5_UHIST,1,100)
_cItemcta  := SC5->C5_ITEMCTA
_cLvl      := SC5->C5_CLVL   


DBSELECTAREA("SC6")
DBSETORDER(1)
IF DBSEEK(xFilial("SC6")+SD2->D2_PEDIDO,.T.)
    cCLVL   := SC6->C6_CLVL
    cITEM   := SC6->C6_ITEMCTA
ENDIF


/*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
ÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄ
ÄÄÄÄÄPOSICIONA TITULO DE ISS A PAGAR PARA PREENCHER O HISTORICO ÄÄÄÄÄ
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄ*/
dbselectarea("SE2")
dbsetorder(1)
IF dbseek(xfilial()+SF2->F2_PREFIXO+SF2->F2_DUPL+' '+'TX '+cForISS)

    if SE2->E2_ORIGEM == "MATA460 "
        If reclock("SE2",.F.)
            SE2->E2_HIST := SUBSTR('FAT NF: '+SF2->F2_SERIE+' '+SF2->F2_DOC+" - "+SA1->A1_NOME,1,100)
            SE2->E2_CLVL 	:= cCLVL //Incluido _CLVL/_ITEM
            SE2->E2_ITEMCTA	:= cITEM //Incluido _CLVL/_ITEM
            msunlock()
        endif
    ENDIF
ENDIF


/*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
ÄÄÄÄÄGRAVA CONTROLE DE GARANTIA TABELA Z22 - INTEGMAX ÄÄÄÄÄ PREPARA DOC
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ*/
xEmp1 := SuperGetMv("MV_UFILMX",.F.,"")

IF cNumemp $ xEmp1

    IF SC5->C5_UGERGAR == "1"

    DBSELECTAREA("Z22")
    DBSETORDER(1)
    IF DBSEEK(xFilial("Z22")+_z23Id)
        IF RECLOCK("Z22",.F.)
            Z22->Z22_NOTA   := SF2->F2_DOC
            Z22->Z22_SERIE  := SF2->F2_SERIE
            Z22->Z22_CLIFOR := SF2->F2_CLIENTE
            Z22->Z22_LOJA   := SF2->F2_LOJA
            Z22->Z22_PEDIDO := SD2->D2_PEDIDO
            Z22->(MSUNLOCK())
        ENDIF
        
    ENDIF
        //Marca como processo enviado 
        //Flaga como enviado

    DBSELECTAREA("SC6")
    DBSETORDER(1)
    IF DBSEEK(xFilial("SC6")+SD2->D2_PEDIDO,.T.)
        while !EOF() .AND. xFilial("SC6")+SC6->C6_NUM == SD2->D2_FILIAL+SD2->D2_PEDIDO
            for Z := 1 to SC6->C6_QTDVEN

                dbSelectArea("Z23")
                DBSETORDER(6)
                IF DBSEEK(xFilial("Z23")+alltrim(_z23Id)+SC6->C6_PRODUTO+"                                        "+" ")
                    IF RECLOCK("Z23",.F.)
                    Z23->Z23_PEDVEN := SC6->C6_NUM
                    Z23->Z23_CHAVE  := SC6->C6_NUM+SC6->C6_ITEM
                    Z23->Z23_ORIGEM := 'MATA460' 
                    Z23->Z23_XPED   := "S"
                    Z23->(MSUNLOCK())
                    ENDIF
                ENDIF
            next Z
        DBSELECTAREA("SC6")
        DBSKIP()    
        enddo
    ENDIF	

    FINDZ23()		
   ENDIF
endif

/*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
ÄÄÄÄÄPOSICIONA TITULO A RECEBER ÄÄÄÄÄ
ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ*/
dbselectarea("SE1")
ordse1:=indexord()
recse1:=recno()
dbsetorder(2)
/*
if dbseek(xfilial()+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL)
    while !eof() .and. SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL == SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
        */
        IF RTRIM(SE1->E1_ORIGEM) == "MATA460"
            IF SE1->(DBSEEK(XFILIAL("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL))
                WHILE !SE1->(EOF()) .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == XFILIAL("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL
                    If reclock("SE1",.F.)
                        SE1->E1_CCUSTO  := _cCusto
                        SE1->E1_NATUREZ := _cNaturez
                        SE1->E1_HIST    := SUBSTR(_cHist,1,100)
                        SE1->E1_CLVL    := _cLvl  
                        SE1->E1_ITEMCTA := _cItemcta
                        msunlock()
                    endif

                    dbskip()
                Enddo
            else
//                Alert("Não posicionou SE1 - SF2460I")
            endif
        ENDIF

        If reclock("SF2",.F.) // Incluido por Diorgny para prenchimento do campo SF2->F2_CCUSTO - campo personalizado
            SF2->F2_CCUSTO := _cCusto // Incluido por Diorgny para prenchimento do campo SF2->F2_CCUSTO - campo personalizado

            msunlock() // Incluido por Diorgny para prenchimento do campo SF2->F2_CCUSTO - campo personalizado
        endif // Incluido por Diorgny para prenchimento do campo SF2->F2_CCUSTO - campo personalizado

        /*ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ
        ÄÄÄÄÄPOSICIONA TITULO APAGAR QUANDO DEVOLUÃ‡ÃƒO - NDF - 19/06/2020 ÄÄÄÄÄ
        ÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ*/
        IF SF2->F2_TIPO == "D"
            DBSELECTAREA("SE2")
            DBSETORDER(6)
            DBSEEK(XFILIAL()+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL)
            WHILE !EOF() .AND. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == XFILIAL()+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DUPL
                IF RTRIM(SE2->E2_ORIGEM) == "MATA460"
                    IF RECLOCK("SE2",.F.)
                        SE2->E2_CCUSTO := _cCusto
                        SE2->E2_HIST := SUBSTR(_cHist,1,100)
                        SE2->E2_CLVL    := _cLvl  
                        SE2->E2_ITEMCTA := _cItemcta
                        MSUNLOCK()
                    ENDIF
                ENDIF
                DBSKIP()
            ENDDO
        ENDIF

        // Como o Alias corrente não era o SE1 e sim o SF2, como não foi informado o Alias SE1
        // ou a área SE1 foi selecionada, ao realizar o dbGoTo(recse1) estava disposicionando oo SF2
        // e gerava erro se mais de 1 fatura era gerada.
        // Como o código está gerando erro para todos os casos de geração de mais de uma fatura
        // e as chamadas a RestArea posteriores a estas linhas comentadas ( RESTAREA(AAREA_SE1) e 
        // RESTAREA(AAREA_SC5) ) fazem o correto posicionamento, de forma segura e sem erros,
        // as linhas abaixo foram comentadas, uma vez que geravam erros e eram desnecessários, visto
        // que logo abaixo tem as chamadas ao RestAreas para a SE1 e SC5.
        // dbsetorder(ordse1)
        // dbgoto(recse1)

        // dbselectarea("SC5")
        // dbsetorder(ordsc5)
        // dbgoto(recsc5)

        RESTAREA(AAREA_SE2)
        RESTAREA(AAREA_SE1)
        RESTAREA(AAREA_SC5)
        RESTAREA(AAREA_SC6)
        RESTAREA(AAREA_SD2)
        RESTAREA(AAREA)

        Return(.t.)


Static Function FINDZ23()
	//*************************************
	//Verifica se Baixa o ID garantia    //
	//*************************************
	CQUERY1 := ""
	CQUERY1 := " SELECT *"
	CQUERY1 += " FROM "+RETSQLNAME("Z23")+" Z23 "
	CQUERY1 += " WHERE  Z23_ID = '"+_z23Id+"' AND  Z23_NEWTAG='' AND Z23.D_E_L_E_T_='' AND Z23_PEDVEN='' " //DAND Z23_COD='"+xProd+"' "
	
	IF SELECT("TRB2")!=0
		TRB2->(DBCLOSEAREA())
	ENDIF
	TCQUERY CQUERY1 NEW ALIAS "TRB2" 
	DBSELECTAREA("TRB2")
	DBGOTOP()
	If TRB2->(eof())
		DBSELECTAREA("Z22") 
		DBSETORDER(1)
		IF DBSEEK(xFilial("Z22")+_z23Id)
			MSGINFO("Z22 - ATUALIZOU O STATUS DO ID DE GARANTIA!","SUCESSO!")
			IF RECLOCK("Z22",.F.)       
				Z22->Z22_STATUS := "2"
				MSUNLOCK()	
			ENDIF
		EndIf     
	ENDIF
	TRB2->(DBCLOSEAREA())


RETURN

/*/{Protheus.doc} UpdCarga
Função responsável por atualizar as cargas durante o faturamento dos pedidos de venda da CONASA
@type function
@author Rodrigo Godinho 
@since 21/08/2023
/*/
Static Function UpdCarga()
    Local aArea	        := GetArea()
    Local oDataCarga    := DataCarga():New()

    oDataCarga:UpdByNFCarga(SD2->D2_SERIE, SD2->D2_DOC)

    FreeObj(oDataCarga)
    RestArea(aArea)
Return
