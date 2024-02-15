#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} CNS0001
Verifica existência de Retenção para Medição de Contrato e gera título referente ao valor da retenção
O Vencimento do Título sempre será a data de término da Vigência do Contrato.

@type function
@author	Jorge Heitor T. de Oliveira
@since 28/07/2023
@version P12
@database MSSQL

@history Fonte chamado pelo MT103FIM, desenvolvido para, no momento da entrada da NF de Serviço (Medição) gerar automaticamente o título da retenção, caso haja.

@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
@see MT103FIM.prw
/*/
User Function CNS0001()

   // If podeExecutar()
        FWMsgRun(, { || processaRetencao() },,"Processando título de retenção contratual...")

    //EndIf

Return 

/*
    Verifica se a rotina pode ser executada
*/
Static Function podeExecutar()
    Local lReturn           as logical

    lReturn := .F.

    Begin Sequence
        If ! GetNewPar("CN_RETXGCT",.F.)
            Break

        Endif

        lRet := .T.

    End Sequence

Return lReturn

/*
    Processa dados e avalia se tem Retenção no Contrato Medido
*/
Static Function processaRetencao()
    Local cFilialNF             as character
    Local cNumeroNF             as character
    Local cSerieNF              as character
    Local cFornecedor           as character
    Local cLoja                 as character
    Local aMedicoes             as array
    Local aTitulosRetencao      as array

    cFilialNF := SD1->D1_FILIAL
    cNumeroNF := SD1->D1_DOC
    cSerieNF := SD1->D1_SERIE
    cFornecedor := SD1->D1_FORNECE
    cLoja := SD1->D1_LOJA
    aMedicoes := {}
    aTitulosRetencao := {}

    Begin Sequence

        If !isNotaFiscalMedicao(@aMedicoes,cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
            Break

        EndIf

        If !temRetencao(aMedicoes, @aTitulosRetencao, cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
            Break

        Endif

        geraTituloRetencao(aMedicoes, aTitulosRetencao,cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)

    End Sequence

Return

/*
    Verifica se a nota fiscal que foi incluída tem relação com medição
*/
Static Function isNotaFiscalMedicao(aMedicoes,cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
    Local aArea                 as array
    Local aAreaSC7              as array
    Local nOrderSC7             as numeric
    Local aPedidos              as array
    Local nPedido               as numeric
    Local lReturn               as logical

    Private cItem 
    Private cClasse
    Private cPedFind := ""

    aArea := GetArea()
    aAreaSC7 := SC7->(GetArea())
    nOrderSC7 := SC7->(IndexOrd())
    aPedidos := {}
    nPedido := 0
    lReturn := .F.

    Begin Sequence

        /*
            Verifica se existem pedidos de compra (toda nf de medição obrigatoriamente tem pedido de compra)
        */
        dbSelectArea("SD1")
        dbSetOrder(1)
        dbSeek(cFilialNF + cNumeroNF + cSerieNF + cFornecedor + cLoja)
        If Found()
            While ! SD1->(Eof()) .And. SD1->D1_FILIAL == cFilialNF .And. SD1->D1_DOC == cNumeroNF .And. SD1->D1_SERIE == cSerieNF .And. ;
                    SD1->D1_FORNECE == cFornecedor .And. SD1->D1_LOJA == cLoja

                If !Empty(SD1->D1_PEDIDO)
                    If aScan(aPedidos,{|cPedido| cPedido == SD1->D1_PEDIDO}) <= 0
                        aAdd(aPedidos,SD1->D1_PEDIDO)

                    EndIf

                EndIf

                SD1->(dbSkip())

            End
        
        EndIf

        If Len(aPedidos) == 0
            Break

        EndIf

        aMedicoes := {}

        /*
            Checa se o(s) pedido(s) encontrado(s) possui(em) medição
        */
        dbSelectArea("SC7")
        dbSetOrder(3) //Filial + Fornecedor + Loja + Numero
        
        For nPedido := 1 To Len(aPedidos)
            dbSeek(cFilialNF + cFornecedor + cLoja + aPedidos[nPedido])
            If Found()
                If !Empty(SC7->C7_CONTRA) .And. !Empty(SC7->C7_MEDICAO) //Pedido de Contrato
                    aAdd(aMedicoes,{SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_ITEM, SC7->C7_CONTRA, SC7->C7_CONTREV, SC7->C7_MEDICAO, SC7->C7_ITEMED})
                    If nPedido == 1
                       cClasse :=  SC7->C7_CLVL
                       cItem := SC7->C7_ITEMCTA
                    EndIf
                EndIf

            EndIf

        Next nPedido

        If Len(aMedicoes) == 0
            Break

        EndIf

        lReturn := .T.

    End Sequence

    RestArea(aAreaSC7)
    SC7->(dbSetOrder(nOrderSC7))
    RestArea(aArea)

Return lReturn

/*
    Verifica o contrato medido, se existe retenção para a medição 

    ----------------
    Array aMedicoes:
    ----------------
    aMedicoes[x][1] -> Filial 
    aMedicoes[x][2] -> Pedido de Compra
    aMedicoes[x][3] -> Item do pedido de Compra
    aMedicoes[x][4] -> Contrato
    aMedicoes[x][5] -> Revisão do Contrato
    aMedicoes[x][6] -> Medição
    aMedicoes[x][7] -> Item da Medição
    aMedicoes[x][8] -> Item CONTABIL
    aMedicoes[x][9] -> CLASSE VALOR
*/
Static Function temRetencao(aMedicoes,aTitulosRetencao,cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
    Local aArea             as array
    Local aTitulosMedicao   as array
    Local nTituloMedicao    as numeric
    Local nMedicao          as numeric
    Local lReturn           as logical

    aArea := GetArea()
    aTitulosMedicao := {}
    nTituloMedicao := 0
    nMedicao := 0
    lReturn := .F.

    Begin Sequence

        aTitulosRetencao := {}

        For nMedicao := 1 To Len(aMedicoes)
            If Len(aTitulosMedicao := pegaDadosRetencao(aMedicoes[nMedicao], cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)) > 0
                For nTituloMedicao := 1 To Len(aTitulosMedicao)
                    aAdd(aTitulosRetencao,aTitulosMedicao[nTituloMedicao])

                Next nTitulomedicao

            EndIf
        
        Next nMedicao

        If Len(aTitulosRetencao) == 0
            Break

        Endif

        lReturn := .T.

    End Sequence

Return lReturn

/*
    Obtem dados de retenção relacionados à medição do Pedido

    ----------------
    Array aReturn:
    ----------------
    aReturn[x][1] -> Filial Contrato
    aReturn[x][2] -> Contrato
    aReturn[x][3] -> Revisão
    aReturn[x][4] -> Medição
    aReturn[x][5] -> Valor
    aReturn[x][6] -> RECNO CNT
    aReturn[x][7] -> Vencimento do Titulo (Término do Contrato)
*/
Static Function pegaDadosRetencao(aMedicao, cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
    Local aArea             as array
    Local cAliasRetencao    as character
    Local aReturn           as array

    aArea := GetArea()
    cAliasRetencao := GetNextAlias()
    aReturn := {}

    If Select(cAliasRetencao) > 0 ; (cAliasRetencao)->(dbCloseArea()) ; EndIf 
    
    BeginSQL Alias cAliasRetencao
        SELECT 
            CNT_FILIAL
            ,CNT_CONTRA
            ,SPACE(3) AS REVISAO
            ,CNT_NUMMED
            ,CNT_VLRET
            ,CNT.R_E_C_N_O_ AS RECCNT
            ,CN9_DTFIM AS VENCTO
        FROM
            %Table:CNT% CNT
        INNER JOIN %Table:CN9% CN9 ON
                                    CN9.%NotDel%
                                    AND CN9.CN9_FILIAL = CNT.CNT_FILIAL
                                    AND CN9.CN9_NUMERO = CNT.CNT_CONTRA
                                    
        WHERE
            CNT.%NotDel%
            AND CNT_FILIAL = %Exp:aMedicao[1]%
            AND CNT_CONTRA = %Exp:aMedicao[4]%
            AND CNT_NUMMED = %Exp:aMedicao[6]%
            AND CNT_DTBX   = ''

    EndSql

    Begin Sequence

        dbSelectArea(cAliasRetencao)

        If (cAliasRetencao)->(Eof())
            Break

        EndIf

        While !(cAliasRetencao)->(Eof())
            //Monta Array de retorno para os N titulos encontrados
            aAdd(aReturn,{(cAliasRetencao)->CNT_FILIAL, (cAliasRetencao)->CNT_CONTRA,(cAliasRetencao)->REVISAO ,(cAliasRetencao)->CNT_NUMMED,(cAliasRetencao)->CNT_VLRET,(cAliasRetencao)->RECCNT,(cAliasRetencao)->VENCTO })

            (cAliasRetencao)->(dbSkip())

        End

        (cAliasRetencao)->(dbCloseArea())

    End Sequence

    RestArea(aArea)

Return aReturn

/*
    Efetua geração do(s) Título(s) de Retenção
*/
Static Function geraTituloRetencao(aMedicoes, aTitulosRetencao, cFilialNF, cNumeroNF, cSerieNF, cFornecedor, cLoja)
    Local aArea             as array
    Local aAreaSE2          as array 
    Local nOrderSE2         as numeric
    Local aEstruturaSE2     as array
    Local aTitulos          as array
    Local aTemp             as array
    Local nCampo            as numeric
    Local cCampo            as character
    Local nTituloRetencao   as numeric
    Local cPrefE2           as character
    Local cNumE2            as character
    Local cParcela          := ""
    Local cNatAtu         := GETMV( "CN_NATATU" )  // Natreza para atualização de retençoes ja efetuadas
    Local cNatAnt         := ""  // Natureza anterior
    Local oDataBC	:= BancoDeConhecimentoData():New() 
	Local aDocs		:= {}
    Local nI        := 0
    Local cMsgErro  := ""
    Local oEntCopia

    aArea := GetArea()
    aAreaSE2 := SE2->(GetArea())
    nOrderSE2 := SE2->(IndexOrd())
    aEstruturaSE2 := SE2->(dbStruct())
    aTitulos := {}
    aTemp := {}
    nCampo := 0
    cCampo := ""
    nTituloRetencao := 0

    /*
        Localiza o título recem gerado para a Nota Fiscal 
    */
    dbSelectArea("SE2")
    dbSetOrder(6)
    dbSeek(cFilialNF + cFornecedor + cLoja + cSerieNF + cNumeroNF) // FIIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA
    If Found()
        
        cPrefE2 := SE2->E2_PREFIXO
        cNumE2  := SE2->E2_NUM
        aDocs   := oDataBC:GetByEntidade("SE2")
        //Inicia o controle de transação
        Begin Transaction
           
            If Empty(SE2->E2_PARCELA)
                cParcela := "001"
                RecLock("SE2",.F.)
                    SE2->E2_PARCELA := cParcela
                  IF INCLUI  
                    SE2->E2_ITEMCTA := SC7->C7_ITEMCTA
                    SE2->E2_CLVL    := SC7->C7_CLVL
                  Else 
                    SE2->E2_ITEMCTA := SD1->D1_ITEMCTA
                    SE2->E2_CLVL    := SD1->D1_CLVL
                  EndIf  
                SE2->(MsUnlock())
                For nI := 1 To Len(aDocs)
                    oEntCopia := EntidadeAC9():New()
                    oEntCopia:cEntidade := aDocs[nI]:cEntidade
                    oEntCopia:cKeyEnt := aDocs[nI]:cKeyEnt
                    oEntCopia:oEntACB := aDocs[nI]:oEntACB
                    oDataBC:UpdateRelation(@oEntCopia, @cMsgErro)
                    FreeObj(oEntCopia)
                Next
            Else  //Avaliar parcelamento por condicao de pagamento para incluir uma última parcela
                While !SE2->(EOF()) .AND. (SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM )  == cFilialNF+cFornecedor+cLoja+cPrefE2+cNumeroNF)
                  If ALLTRIM(SE2->E2_TIPO) == 'NF'
                    cParcela := SE2->E2_PARCELA
                  ENDIF  
                    SE2->(DBSKIP())
                EndDo
                cParcela := StrZero(val(cParcela)+1,3,0)
            EndIf

            /*
                Cria registro do novo título
            */
            For nTituloRetencao := 1 To Len(aTitulosRetencao)
                aTemp := {}
                cParcela := StrZero( Val(cParcela)+1,3,0)   //SOMA 1 na cParcela)

                    If aTitulosRetencao[nTituloRetencao][5] > 0
                      
                          aAdd(aTemp,{"E2_PREFIXO" ,SE2->E2_PREFIXO,Nil}) 
                        
                        If INCLUI // CASO SEJA INCLUSAO PEGA DADOS DO PEDIDO POSSICIONADO
                          aAdd(aTemp,{"E2_CO"      ,SC7->C7_CO,Nil})
                          aAdd(aTemp,{"E2_CCUSTO"  ,SC7->C7_CC,Nil})
                          aAdd(aTemp,{"E2_ITEMCTA" ,SC7->C7_ITEMCTA,Nil})
                          aAdd(aTemp,{"E2_CLVL"    ,SC7->C7_CLVL,Nil})
                        ELSE // SE FOR ATUALIZAÇÃO DE NF QUE NAO GEROU RETENÇÃO CORRETA PEGA DA NF
                          aAdd(aTemp,{"E2_CO"      ,SD1->D1_CO,Nil})
                          aAdd(aTemp,{"E2_CCUSTO"  ,SD1->D1_CC,Nil})
                          aAdd(aTemp,{"E2_ITEMCTA" ,SD1->D1_ITEMCTA,Nil})
                          aAdd(aTemp,{"E2_CLVL"    ,SD1->D1_CLVL,Nil})
                        ENDIF
                        
                          aAdd(aTemp,{"E2_NUM"     ,SE2->E2_NUM,Nil})
                          aAdd(aTemp,{"E2_PARCELA" ,cParcela,Nil})
                          aAdd(aTemp,{"E2_TIPO"    ,SE2->E2_TIPO,Nil})
                        
                        IF INCLUI
                          aAdd(aTemp,{"E2_NATUREZ" ,SC7->C7_CO,Nil})
                        ELSE 
                          cNatAnt := SD1->D1_CO
                          aAdd(aTemp,{"E2_NATUREZ" ,cNatAtu,Nil})
                        ENDIF 
                          
                          aAdd(aTemp,{"E2_FORNECE" ,SE2->E2_FORNECE,Nil})
                          aAdd(aTemp,{"E2_LOJA"    ,SE2->E2_LOJA,Nil})
                          aAdd(aTemp,{"E2_FORNECE" ,SE2->E2_FORNECE,Nil})
                          aAdd(aTemp,{"E2_EMISSAO" ,SE2->E2_EMISSAO,Nil})
                          aAdd(aTemp,{"E2_VENCTO"  ,StoD(aTitulosRetencao[nTituloRetencao][7]),Nil})
                          aAdd(aTemp,{"E2_VALOR"   ,aTitulosRetencao[nTituloRetencao][5], Nil})
                          aAdd(aTemp,{"E2_HIST"    ,"TITULO RETENCAO DE CONTRATO",Nil})
                          aAdd(aTemp,{"E2_ORIGEM"  ,"MATA100",Nil})
                    
                    EndIf    
                    
                
             If Len(aTemp) > 0 
                aAdd(aTitulos,aTemp)
             EndIf
                cAliasAtual := Alias()

                /*
                    Exclui o registro da tabela CNY
                
                dbSelectArea("CNY")
                dbGoTo(aTitulosRetencao[nTituloRetencao][6])
                RecLock("CNY",.F.)
                    dbDelete()
                CNY->(MsUnlock())
               */
                dbSelectArea(cAliasAtual)

            Next nTituloRetencao

            For nTituloRetencao := 1 To Len(aTitulos)
                lMsErroAuto := .F.
                   
                   MSExecAuto({|x,y| FINA050(x,y)}, aTitulos[nTituloRetencao], 3)
                
                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction()
                    Exit
                ELSE
                  If !INCLUI 
                      Alert("Titulo retenção incluido com sucesso")
                      Reclock("SE2",.F.)
                          SE2->E2_NATUREZ := cNatAnt 
                      SE2->(MsUnlock())
                  EndIf
                    For nI := 1 To Len(aDocs)
                        oEntCopia := EntidadeAC9():New()
                        oEntCopia:cEntidade := "SE2"
                        oEntCopia:oEntACB := aDocs[nI]:oEntACB
                        oDataBC:CreateRelation(@oEntCopia, @cMsgErro)
                        FreeObj(oEntCopia)
                    Next
                EndIf

            Next nTituloRetencao

        End Transaction

    EndIf    

    RestArea(aAreaSE2)
    SE2->(dbSetOrder(nOrderSE2))
    RestArea(aArea)

Return
