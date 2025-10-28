CREATE OR REPLACE PROCEDURE NAGP_BKLGRS_EXT_PRODUTO (psTipoAgrup VARCHAR2) IS

    v_file UTL_FILE.file_type;
    v_line VARCHAR2(32767);
    v_Targetcharset varchar2(40 BYTE);
    v_Dbcharset varchar2(40 BYTE);
    v_Cabecalho VARCHAR2(4000);
    v_LineConteudo VARCHAR2(4000);
    v_Periodo VARCHAR2(10);
    v_buffer CLOB;
    v_chunk_size CONSTANT PLS_INTEGER := 32000; -- Ajuste conforme necessário
    v_tipoagrup VARCHAR2(30);

BEGIN
  
    SELECT REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'/','_') 
      INTO v_Periodo
      FROM DUAL;
      
    IF psTipoAgrup = 'F' THEN
       v_tipoagrup := 'Full';
    ELSIF psTipoAgrup = 'I' THEN
       v_tipoagrup := 'Incremental';
    ELSE
       v_tipoagrup := v_Periodo;
    END IF;
    -- Abre o arquivo para escrita
    v_file := UTL_FILE.fopen('BACKLGRS', 'Ext_Bklgrs_Produto_'||v_tipoagrup||'.csv', 'w', 32767);

    -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
    SELECT LISTAGG(COLUMN_NAME,';') WITHIN GROUP (ORDER BY COLUMN_ID)
      INTO v_Cabecalho
      FROM ALL_TAB_COLUMNS A
     WHERE A.table_name = 'NAGV_BKLGRS_PRODUTO_V2'
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
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados

      FOR bs IN (SELECT *                                           
                    FROM NAGV_BKLGRS_PRODUTO_v2 X
                   WHERE 1=1
                     AND TRUNC(DTA_ALT) = CASE WHEN psTipoAgrup = 'F' THEN TRUNC(DTA_ALT) ELSE TRUNC(SYSDATE) -1 END
                 )

      LOOP

      v_line := bs.IDPRODUTO||';'||
                bs.DESCRICAOCOMPLETA||';'||
                bs.DESCRICAORESUMIDA||';'||
                bs.UNIDADE||';'||
                bs.CATEGORIA||';'||
                bs.GRUPO||';'||
                bs.SUBGRUPO||';'||
                bs.MARCA||';'||
                bs.MARCAPROPRIA||';'||
                bs.PRODUTOSAZONAL||';'||
                bs.IDMATERIALPAI||';'||
                bs.DESCRICAOMATERIALPAI||';'||
                bs.IDFORNECEDOR||';'||
                bs.NOMEFORNECEDOR||';'||
                bs.EAN||';'||
                bs.DESC_HUMANIZADA||';'||
                bs.IND_INTEGRA_ECOMM||';'||bs.URL||';'||bs.IND_UTIL_PROD;
              
      v_buffer := v_buffer || v_line || CHR(10); -- Adiciona nova linha ao buffer        
        
        IF LENGTH(v_buffer) > v_chunk_size THEN
            UTL_FILE.put_line(v_file, v_buffer); -- Escreve o buffer no arquivo
            v_buffer := ''; -- Limpe o buffer
            
        END IF;
        
    END LOOP;
    
    -- Grava o restante do buffer no final (burro esqueceu)
    IF v_buffer IS NOT NULL THEN
        UTL_FILE.put_line(v_file, v_buffer);
        v_buffer := '';
    END IF;
    
    -- Fecha o arquivo
    UTL_FILE.fclose(v_file);

COMMIT;
EXCEPTION

    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;
        RAISE;

END;
