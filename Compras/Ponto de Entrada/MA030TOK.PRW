/*�����������������������������������������������������������������������Ŀ��
���Funcao    �MA030TOK   � Aut.  �Everton Forti         � Data �03.07.2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao Conta Or�amentaria + Centro de Custo Tabela Z01   ���
�������������������������������������������������������������������������Ĵ��
���M�dulo: Compras   			Rotina:Cliente				              ���
�������������������������������������������������������������������������Ĵ*/

User Function MA030TOK()

Local lValido   := .T.

IF !INCLUI
	M->A1_UDATALT    := DDATABASE
ENDIF

Return(lValido)
