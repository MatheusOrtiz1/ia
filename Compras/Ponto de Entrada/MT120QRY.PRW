#Include "Protheus.ch"
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  MT120QRY    บAutor  ณEVERTON FORTI      บ Data ณ  29/08/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltro na tela do pedido de compra (mostrar apenas um item  บฑฑ
ฑฑบ                                                 do pedido no mbrowse) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CONASA                                                      บฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT120QRY()
    Local cRet := ""
    Local cQry := ""
    Local MVUQRYSC7 := SUPERGETMV("MV_UQRYSC7",.F.,.F.)
 
    IF MVUQRYSC7
        //Selecionando os dados
        cQry := " SELECT " + CRLF
        cQry += "     SC7.R_E_C_N_O_ " + CRLF
        cQry += " FROM " + CRLF
        cQry += "     "+RetSQLName('SC7')+" SC7 " + CRLF
        cQry += "     INNER JOIN ( " + CRLF
        cQry += "         SELECT DISTINCT " + CRLF
        cQry += "             SC7_PRIN.C7_NUM AS PEDIDO, " + CRLF
        cQry += "             ( " + CRLF
        cQry += "                 SELECT TOP 1 " + CRLF
        cQry += "                     SC7_ITE.C7_ITEM " + CRLF
        cQry += "                 FROM " + CRLF
        cQry += "                     "+RetSQLName('SC7')+" SC7_ITE " + CRLF
        cQry += "                 WHERE " + CRLF
        cQry += "                     SC7_ITE.C7_FILIAL = SC7_PRIN.C7_FILIAL " + CRLF
        cQry += "                     AND SC7_ITE.C7_NUM = SC7_PRIN.C7_NUM " + CRLF
        cQry += "                     AND SC7_ITE.D_E_L_E_T_ = ' ' " + CRLF
        cQry += "                 ORDER BY " + CRLF
        cQry += "                     SC7_ITE.C7_ITEM DESC " + CRLF
        cQry += "             ) AS ULT_ITEM " + CRLF
        cQry += "         FROM " + CRLF
        cQry += "             "+RetSQLName('SC7')+" SC7_PRIN " + CRLF
        cQry += "         WHERE " + CRLF
        cQry += "             SC7_PRIN.C7_FILIAL = '"+FWxFilial('SC7')+"' " + CRLF
        cQry += "             AND SC7_PRIN.D_E_L_E_T_ = ' ' " + CRLF
        cQry += "     ) TAB_AUX ON ( " + CRLF
        cQry += "         SC7.C7_NUM  = TAB_AUX.PEDIDO " + CRLF
        cQry += "         AND SC7.C7_ITEM = TAB_AUX.ULT_ITEM " + CRLF
        cQry += "     ) " + CRLF
        cQry += " WHERE " + CRLF
        cQry += "     SC7.C7_FILIAL = '"+FWxFilial('SC7')+"' " + CRLF
        cQry += "     AND SC7.D_E_L_E_T_ = ' ' " + CRLF
        
        //Montando retorno do ponto de entrada
        cRet := " R_E_C_N_O_ IN ("+cQry+") "
    ENDIF

Return cRet
