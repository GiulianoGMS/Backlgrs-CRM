CREATE OR REPLACE PROCEDURE NAGP_BKLGRS_EXT_PESSOA_v2(psTipoAgrup VARCHAR2) IS

  v_file          UTL_FILE.file_type;
  v_line          VARCHAR2(32767);
  v_Targetcharset varchar2(40 BYTE);
  v_Dbcharset     varchar2(40 BYTE);
  v_Cabecalho     VARCHAR2(4000);
  v_Periodo       VARCHAR2(10);
  v_buffer        CLOB;
  v_chunk_size CONSTANT PLS_INTEGER := 32000;

  v_tipoagrup VARCHAR2(300);

  -- NOVOS CONTROLES
  v_qtd_linhas  NUMBER := 0;
  v_qtd_arquivo NUMBER := 1;
  v_limite CONSTANT NUMBER := 500000;

  -- PROCEDURE PARA ABRIR ARQUIVO
  PROCEDURE abre_arquivo IS
  BEGIN
    v_file := UTL_FILE.fopen('BACKLGRS_GENERATING',
                             'Ext_Bklgrs_Pessoa_' || v_tipoagrup || '_' ||
                             LPAD(v_qtd_arquivo, 3, '0') || '.csv',
                             'w',
                             32767);
  
    -- escreve cabeçalho sempre
    UTL_FILE.put_line(v_file, v_Cabecalho);
  END;

BEGIN

  SELECT REPLACE(TO_CHAR(SYSDATE - 1, 'DD/MM/YYYY'), '/', '_')
    INTO v_Periodo
    FROM DUAL;

  IF psTipoAgrup = 'F' THEN
    v_tipoagrup := 'Full';
  ELSIF psTipoAgrup = 'I' THEN
    v_tipoagrup := 'Incremental';
  ELSE
    v_tipoagrup := v_Periodo;
  END IF;

  -- HEADER
  SELECT LISTAGG(COLUMN_NAME, ';') WITHIN GROUP(ORDER BY COLUMN_ID)
    INTO v_Cabecalho
    FROM ALL_TAB_COLUMNS
   WHERE table_name = 'NAGV_BKLGRS_PESSOA_V2';

  -- ABRE PRIMEIRO ARQUIVO
  abre_arquivo;

  FOR bs IN (SELECT * FROM NAGV_BKLGRS_PESSOA_v2) LOOP
  
    v_line := bs.tipo_cliente || ';' || bs.ID_NAGUMO || ';' || bs.CPF || ';' ||
              bs.first_name || ';' || bs.middle_name || ';' || bs.last_name || ';' ||
              bs.full_name || ';' || bs.DATA_CADASTRO || ';' || bs.sexo || ';' ||
              bs.DATA_NASCIMENTO || ';' || bs.ENDERECO || ';' || bs.NUMERO || ';' ||
              bs.Cidade || ';' || bs.ESTADO || ';' || bs.CEP || ';' ||
              bs.COMPLEMENTO || ';' || bs.PAIS || ';' || bs.PHONE || ';' ||
              bs.Email || ';' || bs.TELEFONE || ';' || bs.PUSH_DEVICE_IDS;
  
    v_buffer     := v_buffer || v_line || CHR(10);
    v_qtd_linhas := v_qtd_linhas + 1;
  
    -- escreve em bloco
    IF LENGTH(v_buffer) > v_chunk_size THEN
      UTL_FILE.put_line(v_file, v_buffer);
      v_buffer := '';
    END IF;
  
    --  TROCA DE ARQUIVO
    IF v_qtd_linhas >= v_limite THEN
    
      -- flush buffer
      IF v_buffer IS NOT NULL THEN
        UTL_FILE.put_line(v_file, v_buffer);
        v_buffer := '';
      END IF;
    
      UTL_FILE.fclose(v_file);
    
      v_qtd_arquivo := v_qtd_arquivo + 1;
      v_qtd_linhas  := 0;
    
      abre_arquivo;
    
    END IF;
  
  END LOOP;

  -- grava resto
  IF v_buffer IS NOT NULL THEN
    UTL_FILE.put_line(v_file, v_buffer);
  END IF;

  UTL_FILE.fclose(v_file);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(v_file) THEN
      UTL_FILE.fclose(v_file);
    END IF;
  
    DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  
    RAISE;
END;
