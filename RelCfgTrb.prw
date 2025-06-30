#Include "Protheus.ch"
#Include "TOTVS.ch"
#Include "REPORT.ch"
#Include "TBICONN.CH"
#include "Topconn.ch"
 
/*--------------------------------------------------------------------*
| Func:  RelCfgTrb                                                    |
| Autor: Edmar Paranhos                                               |
| Data:  17/06/2025                                                   |
| Desc:  Movimentos Entradas e Saídas com Regras Tributárias.         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
 
User Function RelCfgTrb()
 
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Declaracao de variaveis                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
    Private oReport  := Nil
    Private oSecCab  := Nil
 
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Definicoes/preparacao para impressao      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
    ReportDef()
    oReport :PrintDialog()  
 
Return Nil
 
/*--------------------------------------------------------------------*
| Func:  ReportDef                                                    |
| Autor: Edmar Paranhos                                               |
| Data:  18/06/2024                                                   |
| Desc:  Definição da estrutura do relatório.                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
 
Static Function ReportDef()
 
    Private cPerg := "RelCfgTrb"
 
    AjustaSX1()
 
    oReport := TReport():New("RelCfgTrb","Movs. Regras Tributarias",cPerg,{|oReport| PrintReport(oReport)},"Movs. Regras Tributarias")
    oReport:SetLandscape(.T.)
 
    Pergunte("RelCfgTrb",.F.)
 
    oReport:SetPortrait()
 
    oSecCab := TRSection():New( oReport , "Movs. Regras Tributarias", {"QRYTRB"} )
 
//FT_FILIAL, FT_ENTRADA, FT_EMISSAO, FT_PRODUTO, FT_POSIPI, B1_ORIGEM, F7_GRPCLI, B1_GRTRIB, FT_TES,FT_ESTADO, F7_TIPOCLI, 
//FT_NFISCAL, FT_CFOP, FT_CLIEFOR, FT_LOJA, FT_VALCONT, FT_BASEICM, FT_ALIQICM, 
//FT_VALICM, FT_ICMSRET, FT_VALIPI, FT_BASEPIS, FT_BASECOF, FT_ALIQPIS, FT_ALIQCOF, FT_VALPIS, FT_VALCOF, FT_CSTPIS
       
        TRCell():New( oSecCab, "FT_FILIAL","QRYTRB","Filial")
        TRCell():New( oSecCab, "FT_ENTRADA","QRYTRB","DT.Entrada")
        TRCell():New( oSecCab, "FT_EMISSAO","QRYTRB","DT.Emissao")
        TRCell():New( oSecCab, "FT_PRODUTO","QRYTRB","Produto")
        TRCell():New( oSecCab, "FT_POSIPI","QRYTRB","NCM")
        TRCell():New( oSecCab, "B1_ORIGEM","QRYTRB","Origem")
        TRCell():New( oSecCab, "F7_GRPCLI","QRYTRB","Grp.Cli.For")
        TRCell():New( oSecCab, "B1_GRTRIB","QRYTRB","Grp.Trib.")
        TRCell():New( oSecCab, "FT_TES","QRYTRB","TES")
        TRCell():New( oSecCab, "FT_ESTADO","QRYTRB","UF")
        //TRCell():New( oSecCab, "F7_TIPOCLI","QRYTRB","Tipo.Cli")
        //TRCell():New( oSecCab, "FT_NFISCAL","QRYTRB","N.Fiscal")
        TRCell():New( oSecCab, "FT_CFOP","QRYTRB","CFOP")
        //TRCell():New( oSecCab, "FT_CLIEFOR","QRYTRB","Cli/For")
        //TRCell():New( oSecCab, "FT_LOJA","QRYTRB","Loja")
        //TRCell():New( oSecCab, "FT_VALCONT","QRYTRB","Vlr.Contabil")
        //TRCell():New( oSecCab, "FT_BASEICM","QRYTRB","Base ICMS")
        TRCell():New( oSecCab, "FT_ALIQICM","QRYTRB","Alq.ICMS")
        TRCell():New( oSecCab, "FT_ALIQIPI","QRYTRB","Alq.IPI")
        //TRCell():New( oSecCab, "FT_VALICM","QRYTRB","Vlr.ICMS")
        //TRCell():New( oSecCab, "FT_ICMSRET","QRYTRB","ICMS Retido")
        //TRCell():New( oSecCab, "FT_VALIPI","QRYTRB","Vlr.IPI")
        //TRCell():New( oSecCab, "FT_VALPIS","QRYTRB","PIS")
        //TRCell():New( oSecCab, "FT_VALCOF","QRYTRB","COFINS")
        TRCell():New( oSecCab, "FT_ALIQPIS","QRYTRB","Alq.PIS")
        TRCell():New( oSecCab, "FT_ALIQCOF","QRYTRB","Alq.COF")
        TRCell():New( oSecCab, "FT_CSTPIS","QRYTRB","CST PIS/COF")

      

Return(oReport)
 
/*--------------------------------------------------------------------*
| Func:  PrintReport()                                                |
| Autor: Edmar Paranhos                                               |
| Data:  17/06/2024                                                   |
| Desc:  Select dos movimentos.                                       |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
 
Static Function PrintReport(oReport)
 
    Local cQuery    := ''
    Local QRYTRB    := GetNextAlias()
    Local oSecCab:= oReport:Section(1)
 
    If Select("QRYTRB") > 0
        Dbselectarea("QRYTRB")
        QRYTRB-> ( DbClosearea())
    EndIf
 
    If mv_par05 == 1//Entradas

        cQuery := "SELECT DISTINCT FT_FILIAL, FT_ENTRADA, FT_EMISSAO, FT_PRODUTO, FT_POSIPI, B1_ORIGEM, F7_GRPCLI, B1_GRTRIB, FT_TES,FT_ESTADO, FT_CFOP, FT_ALIQICM, FT_ALIQIPI, FT_ALIQPIS, FT_ALIQCOF,FT_CSTPIS, FT_CSTCOF " + CRLF
        cQuery += "FROM " + RetSqlName("SFT") + " SFT " + CRLF
        cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = FT_PRODUTO" + CRLF 
        cQuery += "INNER JOIN " + RetSqlName("SF7") + " SF7 ON F7_GRTRIB = B1_GRTRIB" + CRLF
		cQuery += " AND F7_FILIAL = FT_FILIAL" + CRLF
        cQuery += " WHERE FT_ENTRADA   BETWEEN '" + Dtos (mv_par01) + "' AND '" + Dtos (mv_par02) + "' " + CRLF
        cQuery += " AND FT_TIPOMOV = 'E'" + CRLF
        cQuery += " AND SFT.D_E_L_E_T_= '' "+ CRLF
        cQuery += " AND SB1.D_E_L_E_T_= '' "+ CRLF
        cQuery += " AND SF7.D_E_L_E_T_= '' "+ CRLF
        cQuery += " ORDER BY FT_FILIAL, FT_ENTRADA, FT_EMISSAO, FT_PRODUTO, FT_POSIPI, B1_ORIGEM, F7_GRPCLI, B1_GRTRIB, FT_TES,FT_ESTADO"+ CRLF
 
    Endif
 
    If mv_par05 == 2//Saídas
 
        cQuery := "SELECT DISTINCT FT_FILIAL, FT_ENTRADA, FT_EMISSAO, FT_PRODUTO, FT_POSIPI, B1_ORIGEM, F7_GRPCLI, B1_GRTRIB, FT_TES,FT_ESTADO, FT_CFOP, FT_ALIQICM, FT_ALIQIPI, FT_ALIQPIS, FT_ALIQCOF,FT_CSTPIS, FT_CSTCOF " + CRLF
        cQuery += "FROM " + RetSqlName("SFT") + " SFT " + CRLF
        cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = FT_PRODUTO" + CRLF 
        cQuery += "INNER JOIN " + RetSqlName("SF7") + " SF7 ON F7_GRTRIB = B1_GRTRIB" + CRLF
		cQuery += " AND F7_FILIAL = FT_FILIAL" + CRLF
        cQuery += " WHERE FT_ENTRADA   BETWEEN '" + Dtos (mv_par01) + "' AND '" + Dtos (mv_par02) + "' " + CRLF
        cQuery += " AND FT_TIPOMOV = 'S'" + CRLF
        cQuery += " AND SFT.D_E_L_E_T_= '' "+ CRLF
        cQuery += " AND SB1.D_E_L_E_T_= '' "+ CRLF
        cQuery += " AND SF7.D_E_L_E_T_= '' "+ CRLF
        cQuery += " ORDER BY FT_FILIAL, FT_ENTRADA, FT_EMISSAO, FT_PRODUTO, FT_POSIPI, B1_ORIGEM, F7_GRPCLI, B1_GRTRIB, FT_TES,FT_ESTADO"+ CRLF
       
    Endif

    cQuery := ChangeQuery(cQuery)
 
    DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),QRYTRB,.T.,.T.)
 
    TCSetField(QRYTRB, "FT_ENTRADA", "D",8,0)
    TCSetField(QRYTRB, "FT_EMISSAO", "D",8,0)
 
    DBSelectArea(QRYTRB)
    (QRYTRB)->(DBGoTop())
 
    oReport:SetMeter(RecCount())
 
    oSecCab:Init()
 
    oReport:IncMeter()
 
    While !Eof()
 
        If oReport:Cancel()
            Exit
        EndIf

            oSecCab:Cell('FT_FILIAL'):SetValue((QRYTRB)->FT_FILIAL)
            oSecCab:Cell('FT_ENTRADA'):SetValue((QRYTRB)->FT_ENTRADA)
            oSecCab:Cell('FT_EMISSAO'):SetValue((QRYTRB)->FT_EMISSAO)
            oSecCab:Cell('FT_PRODUTO'):SetValue((QRYTRB)->FT_PRODUTO)
            oSecCab:Cell('FT_POSIPI'):SetValue((QRYTRB)->FT_POSIPI)
            oSecCab:Cell('B1_ORIGEM'):SetValue((QRYTRB)->B1_ORIGEM)
            oSecCab:Cell('F7_GRPCLI'):SetValue((QRYTRB)->F7_GRPCLI)                                                                                                                                                                           
            oSecCab:Cell('B1_GRTRIB'):SetValue((QRYTRB)->B1_GRTRIB)
            oSecCab:Cell('FT_TES'):SetValue((QRYTRB)->FT_TES)
            oSecCab:Cell('FT_ESTADO'):SetValue((QRYTRB)->FT_ESTADO)
            //oSecCab:Cell('F7_TIPOCLI'):SetValue((QRYTRB)->F7_TIPOCLI)
            //oSecCab:Cell('FT_NFISCAL'):SetValue((QRYTRB)->FT_NFISCAL)
            oSecCab:Cell('FT_CFOP'):SetValue((QRYTRB)->FT_CFOP)
            //oSecCab:Cell('FT_CLIEFOR'):SetValue((QRYTRB)->FT_CLIEFOR)
            //oSecCab:Cell('FT_LOJA'):SetValue((QRYTRB)->FT_LOJA)
            //oSecCab:Cell('FT_VALCONT'):SetValue((QRYTRB)->FT_VALCONT)
            //oSecCab:Cell('FT_BASEICM'):SetValue((QRYTRB)->FT_BASEICM)
            oSecCab:Cell('FT_ALIQICM'):SetValue((QRYTRB)->FT_ALIQICM)
            oSecCab:Cell('FT_ALIQIPI'):SetValue((QRYTRB)->FT_ALIQIPI)
            //oSecCab:Cell('FT_VALICM'):SetValue((QRYTRB)->FT_VALICM)
            //oSecCab:Cell('FT_ICMSRET'):SetValue((QRYTRB)->FT_ICMSRET)
            //oSecCab:Cell('FT_VALIPI'):SetValue((QRYTRB)->FT_VALIPI)
            oSecCab:Cell('FT_ALIQPIS'):SetValue((QRYTRB)->FT_ALIQPIS)
            oSecCab:Cell('FT_ALIQCOF'):SetValue((QRYTRB)->FT_ALIQCOF)
            oSecCab:Cell('FT_CSTPIS'):SetValue((QRYTRB)->FT_CSTPIS)
            //oSecCab:Cell('FT_CSTPIS'):SetValue((QRYTRB)->FT_CSTCOF)

            oSecCab:PrintLine()
 
            (QRYTRB)->(DBSkip())
 
    Enddo
 
    oSecCab:Finish()
 
    DbSelectArea(QRYTRB)
 
    (QRYTRB)->(DbCloseArea())
 
Return
   
/*--------------------------------------------------------------------*
| Func:  AjustaSX1()                                                  |
| Autor: Edmar Paranhos                                               |
| Data:  17/06/2025                                                   |
| Desc:  Função irá criar a pergunta na tabela de perguntas (SX1).    |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
 
Static Function AjustaSX1()
 
    Local aALIAS := GetArea()                                              
    Local aREGS  := {}
    Local I,J
 
    DbSelectArea("SX1")                                                    
    DbSetOrder(1)                                                          
    cPerg := Padr(cPerg,10)
 
    Aadd(aREGS,{cPerg,"01","Data Mov. De?"  ,'','',"mv_ch1","D",08,0,0,"G","","SFT","","","mv_par01","","","","","","","","","","","","","","","",""})
    Aadd(aREGS,{cPerg,"02","Data Mov. Ate?" ,'','',"mv_ch2","D",08,0,0,"G","","SFT","","","mv_par02","","","","","","","","","","","","","","","",""})
    Aadd(aREGS,{cPerg,"03","Filial De?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
    Aadd(aREGS,{cPerg,"04","Filial Ate?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
  //Aadd(aREGS,{cPerg,"05","Tipo de Movimento?","","","mv_ch5","C",01,0,0,"C","","mv_par05","Entradas","Entradas","Entradas","","","Saidas","Saidas","Saidas","","","Devolucoes","Devolucoes","Devolucoes","","","","","","","","","","","","","","",""})
    Aadd(aREGS,{cPerg,"05","Tipo Movimento?","","","mv_ch5","C",01,0,0,"C","","mv_par05","Entradas","Entradas","Entradas","","","Saidas","Saidas","Saidas","","","","","","","","","","","","","","","","","","","",""})   
    
    For I:=1 To Len(aREGS)
        If !DbSeek(cPerg+aREGS[I,2])                                        
            RecLock("SX1",.T.)                                              
            For J := 1 To FCount()
                If J <= Len(aREGS[I])
                    FieldPut(J,aREGS[I,J])                                  
                EndIf
            Next
            MsUnlock()                                                      
        Endif
    Next
    RestArea(aALIAS)                                                        
 
Return Nil
