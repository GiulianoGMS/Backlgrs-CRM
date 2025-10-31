CREATE OR REPLACE PROCEDURE NAGP_BKLGRS_EXT_PRODUTO(PSTIPOAGRUP VARCHAR2) IS

       V_FILE          UTL_FILE.FILE_TYPE;
       V_LINE CLOB;
      -- V_LINE          VARCHAR2(32767);
       V_TARGETCHARSET VARCHAR2(40 BYTE);
       V_DBCHARSET     VARCHAR2(40 BYTE);
       V_CABECALHO     VARCHAR2(4000);
       V_LINECONTEUDO  VARCHAR2(4000);
       V_PERIODO       VARCHAR2(10);
       V_BUFFER        CLOB;
       V_CHUNK_SIZE CONSTANT PLS_INTEGER := 32000; -- Ajuste conforme necessário
       V_TIPOAGRUP VARCHAR2(30);
       v_erro VARCHAR2(3000);

BEGIN

       SELECT REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), '/', '_')
         INTO V_PERIODO
         FROM DUAL;

       IF PSTIPOAGRUP = 'F'
       THEN
              V_TIPOAGRUP := 'Full';
       ELSIF PSTIPOAGRUP = 'I'
       THEN
              V_TIPOAGRUP := 'Incremental';
       ELSE
              V_TIPOAGRUP := V_PERIODO;
       END IF;
       -- Abre o arquivo para escrita
       V_FILE := UTL_FILE.FOPEN('BACKLGRS',
                                'Ext_Bklgrs_Produto_' || V_TIPOAGRUP || '.csv',
                                'w',
                                32767);

       -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
       SELECT LISTAGG(COLUMN_NAME, ';') WITHIN GROUP(ORDER BY COLUMN_ID)
         INTO V_CABECALHO
         FROM ALL_TAB_COLUMNS A
        WHERE A.TABLE_NAME = 'NAGV_BKLGRS_PRODUTO_V2'
              AND COLUMN_NAME != 'DTA_ALT';
       -- Nao utiliza pq nao deu certo na variavel   
       /*    
       SELECT 'vda.'||LISTAGG(COLUMN_NAME,'||vda.') WITHIN GROUP (ORDER BY COLUMN_ID)
         INTO v_LineConteudo
         FROM ALL_TAB_COLUMNS A
        WHERE A.table_name = 'NAGV_PLUSOFT_PRODUTO'
          AND COLUMN_NAME != 'DATA';
          */
       -- Escreve o cabe¿alho do CSV
       UTL_FILE.PUT_LINE(V_FILE, V_CABECALHO);

       -- Executa a query e escreve os resultados

       FOR BS IN (
  SELECT *
  FROM NAGV_BKLGRS_PRODUTO_V2 X
  WHERE TRUNC(DTA_ALT) = CASE
                           WHEN PSTIPOAGRUP = 'F' THEN TRUNC(DTA_ALT)
                           ELSE TRUNC(SYSDATE) - 1
                         END
)
LOOP
  UTL_FILE.PUT_LINE(
    V_FILE,
    BS.IDPRODUTO || ';' ||
    BS.DESCRICAOCOMPLETA || ';' ||
    BS.DESCRICAORESUMIDA || ';' ||
    BS.UNIDADE || ';' ||
    BS.CATEGORIA || ';' ||
    BS.GRUPO || ';' ||
    BS.SUBGRUPO || ';' ||
    BS.MARCA || ';' ||
    BS.MARCAPROPRIA || ';' ||
    BS.PRODUTOSAZONAL || ';' ||
    BS.IDMATERIALPAI || ';' ||
    BS.DESCRICAOMATERIALPAI || ';' ||
    BS.IDFORNECEDOR || ';' ||
    BS.NOMEFORNECEDOR || ';' ||
    BS.EAN || ';' ||
    BS.DESC_HUMANIZADA || ';' ||
    BS.NOMEPRODUTOECOMM || ';' ||
    BS.IND_INTEGRA_ECOMM || ';' ||
    BS.URL || ';' ||
    BS.IND_UTIL_PROD || ';'
  );
END LOOP;


       -- Grava o restante do buffer no final (burro esqueceu)
       IF V_BUFFER IS NOT NULL
       THEN
              UTL_FILE.PUT_LINE(V_FILE, V_BUFFER);
              V_BUFFER := '';
       END IF;

       -- Fecha o arquivo
       UTL_FILE.FCLOSE(V_FILE);

       COMMIT;
EXCEPTION

       WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(V_LINE);
              IF UTL_FILE.IS_OPEN(V_FILE)
              THEN
                     UTL_FILE.FCLOSE(V_FILE);
              END IF;
              RAISE;
       
END;
