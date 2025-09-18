CREATE OR REPLACE PROCEDURE NAGP_BKLGRS_EXT_FILIAL (psTipoAgrup VARCHAR2) IS

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
    v_qtd       NUMBER(10);

BEGIN
  
    SELECT REPLACE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'/','_') 
      INTO v_Periodo
      FROM DUAL;
    -- Abre o arquivo para escrita
    IF psTipoAgrup = 'F' THEN
       v_tipoagrup := 'Full';
    ELSE
       v_tipoagrup := v_Periodo;
    END IF;
    
    -- Valida se houve insercao de nova loja no d-1
    -- caso o tipo de geracao seja parcial e nao houver nova loja, nao gerar vazio
    
    SELECT COUNT(1) 
      INTO v_qtd
      FROM NAGV_BKLGRS_FILIAL T
     WHERE T.DATA_CAD = TRUNC(SYSDATE) -1;
     
    IF psTipoAgrup = 'F' OR psTipoAgrup != 'F' AND v_qtd > 0 THEN
    
    v_file := UTL_FILE.fopen('BACKLGRS', 'Ext_Bklgrs_Filial_'||v_tipoagrup||'.csv', 'w', 32767);

    -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
    SELECT LISTAGG(COLUMN_NAME,';') WITHIN GROUP (ORDER BY COLUMN_ID)
      INTO v_Cabecalho
      FROM ALL_TAB_COLUMNS A
     WHERE A.table_name = 'NAGV_BKLGRS_FILIAL'
       AND A.column_name != 'DATA_CAD';
    -- Nao utiliza pq nao deu certo na variavel   
       /*    
    SELECT 'vda.'||LISTAGG(COLUMN_NAME,';vda.') WITHIN GROUP (ORDER BY COLUMN_ID)
      INTO v_LineConteudo
      FROM ALL_TAB_COLUMNS A
     WHERE A.table_name = 'NAGV_PLUSOFT_FILIAL'
       AND COLUMN_NAME != 'DATA';
       */
    -- Escreve o cabe¿alho do CSV
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados

      FOR bs IN (SELECT *                                           
                    FROM NAGV_BKLGRS_FILIAL 
                   WHERE 1=1
                     AND DATA_CAD =  CASE WHEN psTipoAgrup = 'F' THEN DATA_CAD ELSE TRUNC(SYSDATE) -1 END)

      LOOP
 
        v_line := bs.IDFILIAL||';'||
                  bs.NOMEFANTASIA||';'||
                  bs.TIPOLOGRADOURO||';'||
                  bs.LOGRADOURO||';'||
                  bs.NUMNUMERO||';'||
                  bs.COMPLEMENTO||';'||
                  bs.BAIRRO||';'||
                  bs.CIDADE||';'||
                  bs.NUMCEP||';'||
                  bs.UF||';'||
                  bs.NUMLAT||';'||
                  bs.NUMLONG||';'||
                  bs.TIPOFILIAL||';'||
                  bs.IDREGIONAL||';'||
                  bs.REGIONAL||';'||
                  bs.NUMMETRAGEM||';'||
                  bs.NUMAREAVENDA||';'||
                  bs.QTDFUNCIONARIOS||';'||
                  bs.FRANQUIA||';'||
                  bs.FLGATIVA||';'||
                  bs.CANALATENDIMENTO||';'||
                  bs.CPFCNPJ;
                  
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
    
    END IF;

COMMIT;
EXCEPTION

    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;
        RAISE;

END;
