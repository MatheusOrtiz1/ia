#Include "Protheus.ch"



/*------------------------------------------------------------------------------------------------------*
 | P.E.:  FA080CHK  
 | Autor : Adriano Guedes   (Gforti)  13/12/2023                                                                                |
 | Desc:  Validação No Baixa do Contas a Pagar  Para Titulos de contratos sem documentos anexos  
 | Uso : CONASA (Cotratos)                                                                               |
 *------------------------------------------------------------------------------------------------------*/
User Function FA080CHK()

Local lOk      := .T.
Local cQry     := ""


   // Faz  busca para verificar se se trata de um titulo do modulo de contratos
    
    cQry     := " SELECT "
    cQry     += "       CND_CONTRA,"
    cQry     += "       CND_REVISA,"
    cQry     += "       CND_NUMMED,"
    cQry     += "       CND_NUMERO "
    cQry     += " FROM "+RetSqlName('SE2')+" SE2 "

    cQry     += " INNER JOIN "+RetSqlName('SD1')+" SD1 "
    cQry     += "        ON D1_FILIAL = E2_FILIAL "
	cQry     += "       AND D1_DOC = E2_NUM "
	cQry     += "       AND D1_SERIE = E2_PREFIXO " 
	cQry     += "       AND D1_FORNECE = E2_FORNECE " 
	cQry     += "       AND D1_LOJA = E2_LOJA "
    cQry     += "       AND SD1.D_E_L_E_T_ = '' "

    cQry     += " INNER JOIN "+RetSqlName('SC7')+" SC7 "
    cQry     += "        ON C7_FILIAL = D1_FILIAL "
    cQry     += "       AND C7_FORNECE = D1_FORNECE "
    cQry     += "       AND C7_LOJA = D1_LOJA "
    cQry     += "       AND C7_NUM = D1_PEDIDO "
    cQry     += "       AND SC7.D_E_L_E_T_ = '' "

    cQry     += " INNER JOIN "+RetSqlName('CND')+" CND "
    cQry     += "        ON CND_FILIAL = C7_FILIAL "
    cQry     += "       AND CND_NUMMED = C7_MEDICAO
    cQry     += "       AND CND.D_E_L_E_T_ = ''

    cQry     += " WHERE E2_FILIAL = E2_FILIAL " 
    cQry     += "       AND E2_NUM = '"+SE2->E2_NUM+"' "
    cQry     += "       AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"' "
    cQry     += "       AND E2_TIPO = '"+SE2->E2_TIPO+"' "
    cQry     += "       AND SE2.D_E_L_E_T_ = '' "
    
    cQry :=ChangeQuery(cQry)
    dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), "ANEXOS", .F., .T.)
    DbSelectArea('ANEXOS')
    ANEXOS->(DBGOTOP( ))
    If !ANEXOS->(EOF()) .And. !EMPTY(ANEXOS->CND_CONTRA)
        DbSelectArea("AC9")
        DbSetOrder(2)
        // Procura anexos no Contrato CN9
        If ! AC9->(DbSeek(xFilial("AC9")+'CN9'+SE2->E2_FILIAL+ANEXOS->CND_CONTRA))
            /* // CASO NAO ENCONTRE ANEXOS NA CN9, BUSCA NA CND (MEDIÇÃO)
             If ! AC9->(DbSeek(xFilial("AC9")+'CND'+SE2->E2_FILIAL+ SE2->E2_FILIAL+ANEXOS->(CND_CONTRA+CND_REVISA+CND_NUMMED)))
                 MSGINFO( "Titulo Ref.Contrato : "+ANEXOS->CND_CONTRA+CRLF+" **CONTRATO NAO POSSUI DOCUMENTOS ANEXADOS**", "DOCUMENTOS OBRIGATORIOS" )
                lOk := .F.
             ENDIF */
        ENDIF
    ENDIF    
    
    ANEXOS->(DBCLOSEAREA())

Return( lOk )
