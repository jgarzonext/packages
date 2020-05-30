--------------------------------------------------------
--  DDL for Package Body PAC_SEPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SEPA" IS
      /*******************************************************************************
      FUNCION f_mandato_activoselect id_domici, extract (xmldoc, '//CstmrDrctDbtInitn/PmtInf[1]') from xml_domiciliaciones;
      Descripcion: Saber si un mandato está activo para la cuenta bancaria y cobrador de una póliza o recibo.
                   Sí se informa el recibo lo busca el mandato de la cuenta bancaria y cobrador bancario del recibo,
                   sino buscará el de la póliza.
      Parámetros:
         psseguro: Número de seguro - Obligatorio
         pnrecibo: Número de recibo - Opcional - Se informa cuando queremos controlarlo por RECIBO
         pccobban: Código de cobrador bancario - Opcional
         pcbancar: Cuenta bancaria - Opcional
         pctipban: Tipo cuenta bancaria - Opcional
         psperson: Identificador de la persona  - Opcional

      Retorna un valor numérico:
      Devuelve un 1 cuando el mandato está activado, un 0 si no lo está y -1 cuando no existe mandato.

   */
   FUNCTION f_mandato_activo(
      psseguro IN recibos.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE DEFAULT NULL,
      pccobban IN recibos.ccobban%TYPE DEFAULT NULL,
      pcbancar IN recibos.cbancar%TYPE DEFAULT NULL,
      pctipban IN recibos.ctipban%TYPE DEFAULT NULL,
      psperson IN recibos.sperson%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vccobban       cobbancario.ccobban%TYPE;
      vcbancar       recibos.cbancar%TYPE;
      vctipban       recibos.ctipban%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro || ' pnrecibo=' || pnrecibo;
      vsperson       tomadores.sperson%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vcestado       mandatos.cestado%TYPE;
      error          NUMBER;
      e_salida       EXCEPTION;
   BEGIN
      vpasexec := 5;

      IF psseguro IS NOT NULL
         AND pccobban IS NOT NULL
         AND pcbancar IS NOT NULL
         AND pctipban IS NOT NULL THEN
         vpasexec := 10;
         vsseguro := psseguro;
         vccobban := pccobban;
         vcbancar := pcbancar;
         vctipban := pctipban;
         vsperson := psperson;
      ELSE
         IF pnrecibo IS NOT NULL THEN
            vpasexec := 20;

            SELECT ccobban, cbancar, ctipban, sperson, sseguro
              INTO vccobban, vcbancar, vctipban, vsperson, vsseguro
              FROM recibos
             WHERE nrecibo = pnrecibo;
         ELSIF psseguro IS NOT NULL THEN
            vpasexec := 30;

            SELECT ccobban, cbancar, ctipban, NULL, sseguro
              INTO vccobban, vcbancar, vctipban, vsperson, vsseguro
              FROM seguros
             WHERE sseguro = psseguro;
         ELSE
            p_tab_error(f_sysdate, f_user, 'PAC_SEPA.f_mandato_activo', vpasexec, vparam,
                        'error en parametros.');
         END IF;
      END IF;

      IF vsperson IS NULL THEN
         vpasexec := 40;
         vsperson := ff_sperson_tomador(vsseguro);
      END IF;

      vpasexec := 50;

      IF vsperson IS NOT NULL
         AND vctipban IS NOT NULL
         AND vcbancar IS NOT NULL
         AND vccobban IS NOT NULL THEN
         BEGIN
            vpasexec := 60;

            SELECT DISTINCT 1
                       INTO vcestado
                       FROM mandatos
                      WHERE sperson = vsperson
                        AND ctipban = vctipban
                        AND cbancar = vcbancar
                        AND ccobban = vccobban
                        AND cestado = 1
                        AND(sseguro = vsseguro
                            OR sseguro IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := -1;
         END;
      ELSE
         vcestado := 0;
      END IF;

      vpasexec := 100;
      RETURN vcestado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SEPA.f_mandato_activo', vpasexec, vparam,
                     SQLERRM);
         RETURN NULL;
   END f_mandato_activo;

   /*************************************************************************
        FUNCTION f_leer_file_rechazo
        Función que lee el fichero de rechazos y lo guarda en la tabla xml_rechazos

        return             : Devuelve 0 si no ha habido ningún error, por lo contrario devuelve el número de error
    *************************************************************************/
   FUNCTION f_leer_file_rechazo(pfichero IN VARCHAR2, ppath IN VARCHAR2 DEFAULT NULL, pidrechazo OUT NUMBER)
      RETURN NUMBER IS
      ft             UTL_FILE.file_type;
      cadena         CLOB;
      cadenaaux      CLOB;
      v_salto        VARCHAR2(10);
      v_idrechazo    NUMBER(8);

      TYPE table_type IS TABLE OF VARCHAR2(32767);

      oXMLTYPE       XMLTYPE ;
      oCLOB          CLOB ;

      xml            table_type := table_type();
      i              NUMBER := 1;
   BEGIN
      v_salto := CHR(10) || CHR(13);   --salto de linea y retorno de carro

      IF ppath IS NULL THEN -- BUG 0036506 - FAL - 10/12/2015
        ft := UTL_FILE.fopen('TABEXT', pfichero, 'r', 32767); -- AGM-4 03/06/2016 Se amplia el campo a 32767 de la línea.
      ELSE
        ft := UTL_FILE.fopen(ppath, pfichero, 'r', 32767);  -- AGM-4 03/06/2016 Se amplia el campo a 32767 de la línea.
      END IF;

      BEGIN
         LOOP
            UTL_FILE.get_line(ft, cadena);
            xml.EXTEND(1);
            xml(i) := cadena;
            i := i + 1;
         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      i := 1;

      FOR i IN xml.FIRST .. xml.LAST LOOP
         IF i = 1 THEN
            cadenaaux := xml(i);
         ELSE
            cadenaaux := cadenaaux || v_salto || xml(i);
         END IF;
      END LOOP;

      UTL_FILE.fclose(ft);

      SELECT seq_xml_rechazo.NEXTVAL
        INTO v_idrechazo
        FROM DUAL;

      oCLOB    := TO_CLOB( cadenaaux ) ;
      oXMLTYPE := XMLTYPE.createXML(oCLOB);

      INSERT INTO xml_rechazos
           VALUES (v_idrechazo, f_sysdate, oXMLTYPE);

      pidrechazo := v_idrechazo;
      COMMIT;
      RETURN 0;
   END f_leer_file_rechazo;

   /*************************************************************************
        FUNCTION f_genera_xml_domis
        Función que genera el xml correspondiente a las domiciliaciones en función de lo que haya
        en las tablas domi_sepa

        param in pcempres
        param in piddomisepa

        return             : Devuelve 0 si no ha habido ningún error, por lo contrario devuelve el número de error
    *************************************************************************/
   FUNCTION f_genera_xml_domis(pcempres IN NUMBER, piddomisepa IN NUMBER)
      RETURN NUMBER IS
      contexto       DBMS_XMLGEN.ctxhandle;
      xmldocv        CLOB;
      v_numdomis     NUMBER(8);
      v_iddetalle    NUMBER(8);
      v_idpago       NUMBER(8);
      v_finsert      DATE;
      v_contador     NUMBER := 1;
      v_version      VARCHAR2(20);
      v_emp          empresas.CEMPRES%TYPE; -- BUG 0036701 - 02/07/15 - JMF
      v_bic          parempresas.NVALPAR%TYPE; -- BUG 0036701 - 02/07/15 - JMF
      v_bicorbei     parempresas.NVALPAR%TYPE; -- BUG 0040690 - 16/04/16 - DCT
      update_sin_array EXCEPTION;   --contiue del  nuevo update sin array!!!
      v_bic_alwz     parempresas.NVALPAR%TYPE; -- BUG 0041958 - 28/04/16 - EDA
   BEGIN
      -- ini BUG 0036701 - 02/07/15 - JMF
      if pcempres is not null then
         v_emp := pcempres;
      else
         v_emp := f_parinstalacion_n('EMPRESADEF');
      end if;
      -- Si el valor del campo BIC es vacío, entonces no generamos el tab BIC
      v_bic := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BIC_OFF'),0);
      -- fin BUG 0036701 - 02/07/15 - JMF

      --INICIO 40690 DCT 14/04/2016
      -- Si el valor del parámetro BICOrBEI está a 1, entonces utilizamos el Tag <Othr> <Id>
      --si no 0 utilizamos el Tag <BICOrBEI>
      v_bicorbei := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BICORBEI_CHANGE'),0);
      --FIN 40690 DCT 14/04/2016

      -- Inicio 0041958 - 28/04/16 - EDA
      -- Si el parametro de empresa 'SEPA_BIC_OFF_ALWZ', esta informado entonces no se genera el tab BIC
      v_bic_alwz := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BIC_OFF_ALWZ'),0);
      -- fin 0041958 - 28/04/16 - EDA

      --Primero comprobamos que haya datos en la tabla domi_sepa
      SELECT COUNT(1)
        INTO v_numdomis
        FROM domi_sepa
       WHERE iddomisepa = piddomisepa;


      SELECT VERSION
        INTO v_version
        FROM v$instance;   --problemas XML entre versiones de BBDD

--      v_version:=  '11.2.0.3.0' ;

      IF v_numdomis > 0 THEN
         --Tabla domi_sepa
         contexto := DBMS_XMLGEN.newcontext('select null as GrpHdr from dual');
         DBMS_XMLGEN.setrowsettag(contexto, 'Document');
         --Header
         DBMS_XMLGEN.setrowtag(contexto, 'CstmrDrctDbtInitn');
         --GETXMLTYPE...
         xmldocv := DBMS_XMLGEN.getxml(contexto, DBMS_XMLGEN.NONE);
         xmldocv := REPLACE( xmldocv, '<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>' );
         DBMS_XMLGEN.closecontext(contexto);
         --Insertamos el xml inicial y lo vamos completando
         v_finsert := f_sysdate;

         INSERT INTO xml_domiciliaciones
                     (id_domici, fecha, xmldoc)
              VALUES (piddomisepa, v_finsert, XMLTYPE(xmldocv));

         BEGIN
            UPDATE xml_domiciliaciones
               SET xmldoc = INSERTCHILDXML(xmldoc, '/Document', '@xmlns',
                                           'urn:iso:std:iso:20022:tech:xsd:pain.008.001.02')
             WHERE id_domici = piddomisepa
               AND fecha = v_finsert;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         UPDATE xml_domiciliaciones
            SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '/Document/CstmrDrctDbtInitn',
                       (SELECT XMLELEMENT
                                  ("GrpHdr", XMLELEMENT("MsgId", s.msgid),
                                   XMLELEMENT("CreDtTm",
                                              REPLACE(TO_CHAR(s.credttm,
                                                              'YYYY-MM-DD HH24:MI:SS'),
                                                      ' ', 'T')),
                                   XMLELEMENT("NbOfTxs", s.nboftxs),
                                   XMLELEMENT
                                         ("CtrlSum",
                                          LTRIM(RTRIM(REPLACE(TO_CHAR(s.ctrlsum,
                                                                      '999999999999990.00'),
                                                              ',', '.')))))
                          FROM domi_sepa s
                         WHERE s.iddomisepa = piddomisepa))
          WHERE id_domici = piddomisepa;

         UPDATE xml_domiciliaciones
            SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '//CstmrDrctDbtInitn/GrpHdr',
                       (SELECT XMLELEMENT
                                     ("InitgPty",
                                      XMLELEMENT("Nm", f_caracteres_sepa(s.initgpty_nm_3)),
                                      XMLELEMENT("Id",
                                                 XMLELEMENT("OrgId",
                                                            XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  othr_id_6)))))
                          FROM domi_sepa s
                         WHERE s.iddomisepa = piddomisepa))
          WHERE id_domici = piddomisepa;

         FOR reg IN (SELECT *
                       FROM domi_sepa_pago
                      WHERE iddomisepa = piddomisepa) LOOP
            v_idpago := reg.idpago;
            --Tabla domi_sepa_pago
            contexto :=
               DBMS_XMLGEN.newcontext
                  ('select pmtinfid as "PmtInfId", pmtmtd as "PmtMtd", btchbookg as "BtchBookg", nboftxs as "NbOfTxs",
                  LTRIM(RTRIM(REPLACE(TO_CHAR(ctrlsum,''999999999999990.00''), '','', ''.''))) "CtrlSum"
               from domi_sepa_pago d where iddomisepa='
                   || piddomisepa || ' and idpago=' || v_idpago);
            --Root message TEMPORAL
            DBMS_XMLGEN.setrowsettag(contexto, 'ROOT_TBL_PAGOS');
            --Header
            DBMS_XMLGEN.setrowtag(contexto, 'PmtInf');
            --GETXMLTYPE...
            xmldocv := DBMS_XMLGEN.getxml(contexto, DBMS_XMLGEN.NONE);
            DBMS_XMLGEN.closecontext(contexto);

            --Añadimos los tags DIRECTOS de la tabla DOMI_SEPA_PAGO
            UPDATE xml_domiciliaciones
               SET xmldoc = APPENDCHILDXML(xmldoc, '//CstmrDrctDbtInitn',
                                           EXTRACT(XMLTYPE(xmldocv), '/ROOT_TBL_PAGOS/PmtInf'))
             WHERE id_domici = piddomisepa;

/*
         FOR reg IN (SELECT *
                       FROM domi_sepa_pago
                      WHERE iddomisepa = piddomisepa) LOOP
            v_idpago := reg.idpago;
*/

            --transformamos los tags INDIRECTOS de la tabla DOMI_SEPA_PAGO

            --OJO: Es OBLIGATORIO que el campo PMTINFID tenga el id del pago: DOMI_SEPA_PAGO.IDPAGO = DOMI_SEPA_PAGO.PMTINFID
            --De esta manera enlazamos el pago de domiciliaciones con el pago XML
            BEGIN
               IF v_version > '11.2.0.2.0' THEN
                  UPDATE xml_domiciliaciones
                     SET xmldoc =
                            APPENDCHILDXML
                               (xmldoc,
                                '//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',

                                --     (xmldoc, '//CstmrDrctDbtInitn/PmtInf['||v_contador||']', NO FUNCIONA!!!!
                                (SELECT XMLELEMENT("PmtTpInf",
                                                   (XMLELEMENT("SvcLvl",
                                                               (XMLELEMENT("Cd", p.svclvl_cd_4)))),
                                                   (XMLELEMENT("LclInstrm",
                                                               (XMLELEMENT("Cd",
                                                                           p.lclinstrm_cd_4)))),
                                                   (XMLELEMENT("SeqTp", p.pmttpinf_seqtp_3)))
                                        || XMLELEMENT("ReqdColltnDt",
                                                      TO_CHAR(p.reqdcolltndt, 'YYYY-MM-DD'))   --afm
                                        || XMLELEMENT
                                                   ("Cdtr",
                                                    XMLELEMENT("Nm",
                                                               f_caracteres_sepa(p.cdtr_nm_3)),
                                                    XMLELEMENT("PstlAdr",
                                                               XMLELEMENT("Ctry",
                                                                          p.pstladr_ctry_4)))
                                        || XMLELEMENT("CdtrAcct",
                                                      (XMLELEMENT("Id",
                                                                  (XMLELEMENT("IBAN",
                                                                              p.id_iban_4)))))
                                        -- ini BUG 0036701 - 02/07/15 - JMF
                                        || XMLELEMENT
                                                  ("CdtrAgt",
                                                   (XMLELEMENT("FinInstnId",
                                                                 decode(v_bic,1,
                                                                     decode(nvl(length(p.fininstnid_bic_4),0),0,null,
                                                                            XMLELEMENT("BIC",p.fininstnid_bic_4)
                                                                           )
                                                                           ,XMLELEMENT("BIC",p.fininstnid_bic_4)))))
                                        -- fin BUG 0036701 - 02/07/15 - JMF
                                        || XMLELEMENT
                                             ("CdtrSchmeId",
                                              (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT
                                                       ("PrvtId",
                                                        (XMLELEMENT
                                                            ("Othr",
                                                             XMLELEMENT("Id", p.othr_id_6),
                                                             XMLELEMENT
                                                                 ("SchmeNm",
                                                                  XMLELEMENT("Prtry",
                                                                             p.schmenm_prtry_7)))))))))
                                   FROM domi_sepa_pago p
                                  WHERE p.iddomisepa = piddomisepa
                                    AND p.idpago = v_idpago)
                                                            --,  'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                                                      --ORDER by P.idpago)
                            )
                   WHERE id_domici = piddomisepa;

               ELSE
                  BEGIN
                --Miramos si existe el salto de línea (LA SELECT devuelve valor pero no actualiza el XMLTYPE!!!!...es como si no fuera XML..devuelve texto sin saltos de línea!!!)

                SELECT (extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]')).getclobval()
                --,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval() (NO LO ENTIENDO --> SIN NAMESPACE!!!)
                  INTO xmldocv
                  FROM xml_domiciliaciones x
                 WHERE id_domici= piddomisepa ;
                      --and instr((extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]'
                      --             ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval(),chr(10)) <> 0;

                     IF INSTR(xmldocv, CHR(10)) = 0 THEN
                        RAISE NO_DATA_FOUND;   --update sin indice en array
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --Si no encuentra saltos de línea en el XML, el XML devuelto no sirve, es más texto que XML (por eso controlo el salto de línea)
                        --(NO SE XQ no funciona XPATH con indice correctamente y no hace el UPDATE!!!!). Este UPDATE es diferente!!!
                        UPDATE xml_domiciliaciones
                           SET xmldoc =
                                  APPENDCHILDXML
                                     (xmldoc, '//CstmrDrctDbtInitn/PmtInf',   --no usamos array (no indicamos el indice)
                                      (SELECT XMLELEMENT
                                                   ("PmtTpInf",
                                                    (XMLELEMENT("SvcLvl",
                                                                (XMLELEMENT("Cd",
                                                                            p.svclvl_cd_4)))),
                                                    (XMLELEMENT("LclInstrm",
                                                                (XMLELEMENT("Cd",
                                                                            p.lclinstrm_cd_4)))),
                                                    (XMLELEMENT("SeqTp", p.pmttpinf_seqtp_3)))
                                              || XMLELEMENT("ReqdColltnDt",
                                                            TO_CHAR(p.reqdcolltndt,
                                                                    'YYYY-MM-DD'))   --afm
                                              || XMLELEMENT
                                                   ("Cdtr",
                                                    XMLELEMENT("Nm",
                                                               f_caracteres_sepa(p.cdtr_nm_3)),
                                                    XMLELEMENT("PstlAdr",
                                                               XMLELEMENT("Ctry",
                                                                          p.pstladr_ctry_4)))
                                              || XMLELEMENT
                                                         ("CdtrAcct",
                                                          (XMLELEMENT("Id",
                                                                      (XMLELEMENT("IBAN",
                                                                                  p.id_iban_4)))))
                                              -- ini BUG 0036701 - 02/07/15 - JMF
                                              || XMLELEMENT
                                                        ("CdtrAgt",
                                                         (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                           decode(nvl(length(p.fininstnid_bic_4),0),0,null,
                                                                                  XMLELEMENT("BIC",p.fininstnid_bic_4)
                                                                                 )
                                                                                 ,XMLELEMENT("BIC",p.fininstnid_bic_4)))))
                                              -- fin BUG 0036701 - 02/07/15 - JMF
                                              || XMLELEMENT
                                                   ("CdtrSchmeId",
                                                    (XMLELEMENT
                                                        ("Id",
                                                         (XMLELEMENT
                                                             ("PrvtId",
                                                              (XMLELEMENT
                                                                  ("Othr",
                                                                   XMLELEMENT("Id",
                                                                              p.othr_id_6),
                                                                   XMLELEMENT
                                                                      ("SchmeNm",
                                                                       XMLELEMENT
                                                                             ("Prtry",
                                                                              p.schmenm_prtry_7)))))))))
                                         FROM domi_sepa_pago p
                                        WHERE p.iddomisepa = piddomisepa
                                          AND p.idpago = v_idpago)
                                                                  --  ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'   (NO LO ENTIENDO --> SIN NAMESPACE!!!)
                                  )
                         WHERE id_domici = piddomisepa;

                        RAISE update_sin_array;   --CONTINUE
                  END;

                  UPDATE xml_domiciliaciones
                     SET xmldoc =
                            APPENDCHILDXML
                               (xmldoc,
                                '//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',

                                --     (xmldoc, '//CstmrDrctDbtInitn/PmtInf['||v_contador||']', NO FUNCIONA!!!!
                                (SELECT XMLELEMENT("PmtTpInf",
                                                   (XMLELEMENT("SvcLvl",
                                                               (XMLELEMENT("Cd", p.svclvl_cd_4)))),
                                                   (XMLELEMENT("LclInstrm",
                                                               (XMLELEMENT("Cd",
                                                                           p.lclinstrm_cd_4)))),
                                                   (XMLELEMENT("SeqTp", p.pmttpinf_seqtp_3)))
                                        || XMLELEMENT("ReqdColltnDt",
                                                      TO_CHAR(p.reqdcolltndt, 'YYYY-MM-DD'))   --afm
                                        || XMLELEMENT
                                                   ("Cdtr",
                                                    XMLELEMENT("Nm",
                                                               f_caracteres_sepa(p.cdtr_nm_3)),
                                                    XMLELEMENT("PstlAdr",
                                                               XMLELEMENT("Ctry",
                                                                          p.pstladr_ctry_4)))
                                        || XMLELEMENT("CdtrAcct",
                                                      (XMLELEMENT("Id",
                                                                  (XMLELEMENT("IBAN",
                                                                              p.id_iban_4)))))
                                        -- ini BUG 0036701 - 02/07/15 - JMF
                                        || XMLELEMENT
                                                  ("CdtrAgt",
                                                   (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                     decode(nvl(length(p.fininstnid_bic_4),0),0,null,
                                                                            XMLELEMENT("BIC",p.fininstnid_bic_4)
                                                                           )
                                                                           ,XMLELEMENT("BIC",p.fininstnid_bic_4)))))
                                        -- fin BUG 0036701 - 02/07/15 - JMF
                                        || XMLELEMENT
                                             ("CdtrSchmeId",
                                              (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT
                                                       ("PrvtId",
                                                        (XMLELEMENT
                                                            ("Othr",
                                                             XMLELEMENT("Id", p.othr_id_6),
                                                             XMLELEMENT
                                                                 ("SchmeNm",
                                                                  XMLELEMENT("Prtry",
                                                                             p.schmenm_prtry_7)))))))))
                                   FROM domi_sepa_pago p
                                  WHERE p.iddomisepa = piddomisepa
                                    AND p.idpago = v_idpago),
                                'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')
                   WHERE id_domici = piddomisepa;

               END IF;
            EXCEPTION
               WHEN update_sin_array THEN
                  NULL;   --continue
               WHEN OTHERS THEN
                  NULL;
            END;

            --Tabla domi_sepa_pago_detalles (todos los TAGS son INDIRECTOS --> se deben calcular según su .XSD relacionado)
            FOR regdet IN (SELECT *
                             FROM domi_sepa_pago_detalle
                            WHERE iddomisepa = piddomisepa
                              AND idpago = v_idpago) LOOP
               v_iddetalle := regdet.iddetalle;

               BEGIN
                  IF v_version > '11.2.0.2.0' THEN
                     UPDATE xml_domiciliaciones
                        SET xmldoc =
                               APPENDCHILDXML

                                  --    (xmldoc, '//CstmrDrctDbtInitn/PmtInf['||v_contador||']',
                               (   xmldoc,
                                   '//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || reg.pmtinfid
                                   || '"]',
                                   (SELECT XMLELEMENT
                                              ("DrctDbtTxInf",
                                               XMLELEMENT("PmtId",
                                                          XMLELEMENT("InstrId",
                                                                     d.pmtid_instrid_4),
                                                          XMLELEMENT("EndToEndId",
                                                                     d.pmtid_endtoendid_4)),
                                               XMLELEMENT
                                                  ("InstdAmt", xmlattributes('EUR' AS "Ccy"),
                                                   LTRIM
                                                      (RTRIM
                                                          (REPLACE
                                                              (TO_CHAR
                                                                    (d.drctdbttxinf_instdamt_3,
                                                                     '999999999999990.00'),
                                                               ',', '.')))),
                                               XMLELEMENT
                                                  ("DrctDbtTx",
                                                   XMLELEMENT
                                                      ("MndtRltdInf",
                                                       XMLELEMENT("MndtId",
                                                                  d.mndtritdinf_mndtid_5),
                                                       XMLELEMENT("DtOfSgntr",
                                                                  d.mndtritdinf_dtofsgntr_5),
                                                       XMLELEMENT("AmdmntInd",
                                                                  d.mndtritdinf_amdmntind_5),
                                                       DECODE
                                                          (d.mndtritdinf_amdmntind_5,
                                                           'false', NULL,
                                                           XMLELEMENT
                                                              ("AmdmntInfDtls",
                                                               XMLELEMENT
                                                                  ("OrgnlMndtId",
                                                                   NVL
                                                                      (d.amdmntind_orgnlmndtid_6,
                                                                       '1')))))),
                                               -- ini BUG 0036701 - 02/07/15 - JMF
                                               -- Inicio 0041958 - 28/04/16 - EDA
                                               XMLELEMENT
                                                    ("DbtrAgt",
                                                     XMLELEMENT("FinInstnId",
                                                                 decode(v_bic_alwz, 1, null,
                                                                         (decode(v_bic,1,
                                                                    decode(nvl(length(d.fininstnid_bic_5),0),0,null,
                                                                            XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                          )
                                                                         ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                               -- Fin 0041958 - 28/04/16 - EDA
                                               -- fin BUG 0036701 - 02/07/15 - JMF
                                               XMLELEMENT
                                                  ("Dbtr",
                                                   XMLELEMENT("Nm",
                                                              f_caracteres_sepa(d.dbtr_nm_4)),
                                                   XMLELEMENT
                                                      ("Id",
                                                       XMLELEMENT
                                                             ("OrgId",
                                                              XMLELEMENT("Othr",
                                                                         XMLELEMENT("Id",
                                                                                    othr_id_7))))),
                                               XMLELEMENT("DbtrAcct",
                                                          XMLELEMENT("Id",
                                                                     XMLELEMENT("IBAN",
                                                                                d.id_iban_5))),
                                               XMLELEMENT
                                                  ("RmtInf",
                                                   XMLELEMENT
                                                           ("Ustrd",
                                                            f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                            )))
                                      FROM domi_sepa_pago_detalle d
                                     WHERE d.iddomisepa = piddomisepa
                                       AND d.idpago = v_idpago
                                       AND d.iddetalle = v_iddetalle)
                                                                     --,  'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                               )
                      WHERE id_domici = piddomisepa;


                  ELSE
                     BEGIN

                    --Miramos si existe el salto de línea (LA SELECT devuelve valor pero no actualiza el XMLTYPE!!!!...es como si no fuera XML..devuelve texto sin saltos de línea!!!)
                    SELECT (extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]')).getclobval()
                    --,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval() (NO LO ENTIENDO --> SIN NAMESPACE!!!)
                      INTO xmldocv
                      FROM xml_domiciliaciones x
                     WHERE id_domici= piddomisepa ;
                          --and instr((extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]'
                          --             ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval(),chr(10)) <> 0;

                        IF INSTR(xmldocv, CHR(10)) = 0 THEN
                           RAISE NO_DATA_FOUND;   --update sin indice en array
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           --Si no encuentra saltos de línea en el XML, el XML devuelto no sirve, es más texto que XML (por eso controlo el salto de línea)
                           --(NO SE XQ no funciona XPATH con indice correctamente y no hace el UPDATE!!!!). Este UPDATE es diferente!!!
                           UPDATE xml_domiciliaciones
                              SET xmldoc =
                                     APPENDCHILDXML
                                        (xmldoc, '//CstmrDrctDbtInitn/PmtInf',
                                         (SELECT XMLELEMENT
                                                    ("DrctDbtTxInf",
                                                     XMLELEMENT
                                                              ("PmtId",
                                                               XMLELEMENT("InstrId",
                                                                          d.pmtid_instrid_4),
                                                               XMLELEMENT("EndToEndId",
                                                                          d.pmtid_endtoendid_4)),
                                                     XMLELEMENT
                                                        ("InstdAmt",
                                                         xmlattributes('EUR' AS "Ccy"),
                                                         LTRIM
                                                            (RTRIM
                                                                (REPLACE
                                                                    (TO_CHAR
                                                                        (d.drctdbttxinf_instdamt_3,
                                                                         '999999999999990.00'),
                                                                     ',', '.')))),
                                                     XMLELEMENT
                                                        ("DrctDbtTx",
                                                         XMLELEMENT
                                                            ("MndtRltdInf",
                                                             XMLELEMENT("MndtId",
                                                                        d.mndtritdinf_mndtid_5),
                                                             XMLELEMENT
                                                                     ("DtOfSgntr",
                                                                      d.mndtritdinf_dtofsgntr_5),
                                                             XMLELEMENT
                                                                     ("AmdmntInd",
                                                                      d.mndtritdinf_amdmntind_5),
                                                             DECODE
                                                                (d.mndtritdinf_amdmntind_5,
                                                                 'false', NULL,
                                                                 XMLELEMENT
                                                                    ("AmdmntInfDtls",
                                                                     XMLELEMENT
                                                                        ("OrgnlMndtId",
                                                                         NVL
                                                                            (d.amdmntind_orgnlmndtid_6,
                                                                             '1')))))),
                                                     -- ini BUG 0036701 - 02/07/15 - JMF
                                                     -- Inicio 0041958 - 28/04/16 - EDA
                                                     XMLELEMENT
                                                          ("DbtrAgt",
                                                           XMLELEMENT("FinInstnId",
                                                                       decode(v_bic_alwz, 1, null,
                                                                               (decode(v_bic,1,
                                                                          decode(nvl(length(d.fininstnid_bic_5),0),0,null,
                                                                                  XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                                )
                                                                               ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                                     -- Fin 0041958 - 28/04/16 - EDA
                                                     -- fin BUG 0036701 - 02/07/15 - JMF
                                                     XMLELEMENT
                                                        ("Dbtr",
                                                         XMLELEMENT
                                                                ("Nm",
                                                                 f_caracteres_sepa(d.dbtr_nm_4)),
                                                         XMLELEMENT
                                                            ("Id",
                                                             XMLELEMENT
                                                                ("OrgId",
                                                                 XMLELEMENT
                                                                         ("Othr",
                                                                          XMLELEMENT("Id",
                                                                                     othr_id_7))))),
                                                     XMLELEMENT
                                                           ("DbtrAcct",
                                                            XMLELEMENT("Id",
                                                                       XMLELEMENT("IBAN",
                                                                                  d.id_iban_5))),
                                                     XMLELEMENT
                                                        ("RmtInf",
                                                         XMLELEMENT
                                                            ("Ustrd",
                                                             f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                             )))
                                            FROM domi_sepa_pago_detalle d
                                           WHERE d.iddomisepa = piddomisepa
                                             AND d.idpago = v_idpago
                                             AND d.iddetalle = v_iddetalle)
                                                                           -- ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                     )
                            WHERE id_domici = piddomisepa;


                           RAISE update_sin_array;   --CONTINUE
                     END;

                     UPDATE xml_domiciliaciones
                        SET xmldoc =
                               APPENDCHILDXML

                                  --    (xmldoc, '//CstmrDrctDbtInitn/PmtInf['||v_contador||']',
                               (   xmldoc,
                                   '//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || reg.pmtinfid
                                   || '"]',
                                   (SELECT XMLELEMENT
                                              ("DrctDbtTxInf",
                                               XMLELEMENT("PmtId",
                                                          XMLELEMENT("InstrId",
                                                                     d.pmtid_instrid_4),
                                                          XMLELEMENT("EndToEndId",
                                                                     d.pmtid_endtoendid_4)),
                                               XMLELEMENT
                                                  ("InstdAmt", xmlattributes('EUR' AS "Ccy"),
                                                   LTRIM
                                                      (RTRIM
                                                          (REPLACE
                                                              (TO_CHAR
                                                                    (d.drctdbttxinf_instdamt_3,
                                                                     '999999999999990.00'),
                                                               ',', '.')))),
                                               XMLELEMENT
                                                  ("DrctDbtTx",
                                                   XMLELEMENT
                                                      ("MndtRltdInf",
                                                       XMLELEMENT("MndtId",
                                                                  d.mndtritdinf_mndtid_5),
                                                       XMLELEMENT("DtOfSgntr",
                                                                  d.mndtritdinf_dtofsgntr_5),
                                                       XMLELEMENT("AmdmntInd",
                                                                  d.mndtritdinf_amdmntind_5),
                                                       DECODE
                                                          (d.mndtritdinf_amdmntind_5,
                                                           'false', NULL,
                                                           XMLELEMENT
                                                              ("AmdmntInfDtls",
                                                               XMLELEMENT
                                                                  ("OrgnlMndtId",
                                                                   NVL
                                                                      (d.amdmntind_orgnlmndtid_6,
                                                                       '1')))))),
                                               -- Inicio 0041958 - 28/04/16 - EDA
                                               XMLELEMENT
                                                    ("DbtrAgt",
                                                     XMLELEMENT("FinInstnId",
                                                                 decode(v_bic_alwz, 1, null,
                                                                         (decode(v_bic,1,
                                                                    decode(nvl(length(d.fininstnid_bic_5),0),0,null,
                                                                            XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                          )
                                                                         ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                               -- Fin 0041958 - 28/04/16 - EDA
                                               XMLELEMENT
                                                  ("Dbtr",
                                                   XMLELEMENT("Nm",
                                                              f_caracteres_sepa(d.dbtr_nm_4)),
                                                   XMLELEMENT
                                                      ("Id",
                                                       XMLELEMENT
                                                             ("OrgId",
                                                              XMLELEMENT("Othr",
                                                                         XMLELEMENT("Id",
                                                                                    othr_id_7))))),
                                               XMLELEMENT("DbtrAcct",
                                                          XMLELEMENT("Id",
                                                                     XMLELEMENT("IBAN",
                                                                                d.id_iban_5))),
                                               XMLELEMENT
                                                  ("RmtInf",
                                                   XMLELEMENT
                                                           ("Ustrd",
                                                            f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                            )))
                                      FROM domi_sepa_pago_detalle d
                                     WHERE d.iddomisepa = piddomisepa
                                       AND d.idpago = v_idpago
                                       AND d.iddetalle = v_iddetalle),
                                   'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')
                      WHERE id_domici = piddomisepa;


                  END IF;
               EXCEPTION
                  WHEN update_sin_array THEN
                     NULL;   --continue
                  WHEN OTHERS THEN
                     NULL;
               END;
            END LOOP;

            v_contador := v_contador + 1;
         END LOOP;
      END IF;

/*
      UPDATE xml_domiciliaciones x
         SET x.xmldoc = XMLTYPE(f_caracteres_sepa(x.xmldoc.getclobval()))
       WHERE x.id_domici = piddomisepa;
*/
      RETURN 0;
   END f_genera_xml_domis;

    /*************************************************************************
       FUNCTION f_genera_xml_transferencias
       Función que genera el xml correspondiente a las transferencias en función de lo que haya
       en las tablas remesas_sepa

       param in pidtransf

       return             : Devuelve 0 si no ha habido ningún error, por lo contrario devuelve el número de error
   *************************************************************************/
   FUNCTION f_genera_xml_transferencias(pidtransf IN NUMBER)
      RETURN NUMBER IS
      contexto       DBMS_XMLGEN.ctxhandle;
      xmldocv        CLOB;
      v_numtransf    NUMBER(8);
      v_idpago       NUMBER(8);
      v_iddetalle    NUMBER(8);
      v_finsert      DATE;
      v_version      VARCHAR2(20);
      v_emp          empresas.CEMPRES%TYPE; -- BUG 0036701 - 02/07/15 - JMF
      v_bic          parempresas.NVALPAR%TYPE; -- BUG 0036701 - 02/07/15 - JMF
      update_sin_array EXCEPTION;   --contiue del  nuevo update sin array!!!
      v_bicorbei     parempresas.NVALPAR%TYPE; -- BUG 0040690 - 16/04/16 - DCT
	    v_numremesa    NUMBER:=0;       -- BUG 0040690 - 26/04/16 - EDA
	    vothr_id_6     remesas_sepa.othr_id_6%TYPE; -- BUG 0040690 - 26/04/16 - EDA
      v_bic_alwz     parempresas.NVALPAR%TYPE; -- BUG 0041958 - 28/04/16 - EDA
   BEGIN
      -- ini BUG 0036701 - 02/07/15 - JMF
      v_emp := f_parinstalacion_n('EMPRESADEF');
      -- Si el valor del campo BIC es vacío, entonces no generamos el tab BIC
      v_bic := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BIC_OFF'),0);
      -- fin BUG 0036701 - 02/07/15 - JMF

      --INICIO 40690 DCT 14/04/2016
      -- Si el valor del parámetro BICOrBEI está a 1, entonces utilizamos el Tag <Othr> <Id>
      --si no 0 utilizamos el Tag <BICOrBEI>
      v_bicorbei := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BICORBEI_CHANGE'),0);
      --FIN 40690 DCT 14/04/2016

      -- Inicio 0041958 - 28/04/16 - EDA
      -- Si el parametro de empresa 'SEPA_BIC_OFF_ALWZ', esta informado entonces no se genera el tab BIC
      v_bic_alwz := NVL(pac_parametros.f_parempresa_n(v_emp,'SEPA_BIC_OFF_ALWZ'),0);
      -- fin 0041958 - 28/04/16 - EDA

      --Primero comprobamos que haya datos en la tabla domi_sepa
      SELECT COUNT(1)
        INTO v_numtransf
        FROM remesas_sepa
       WHERE idremesassepa = pidtransf;


      SELECT VERSION
        INTO v_version
        FROM v$instance;   --problemas entre versiones de BBDD

      --v_version:=  '11.2.0.2.0' ;

      IF v_numtransf > 0 THEN
         --Tabla remesa_sepa
         contexto := DBMS_XMLGEN.newcontext('select null as GrpHdr from dual');
         DBMS_XMLGEN.setrowsettag(contexto, 'Document');
         --Header
         DBMS_XMLGEN.setrowtag(contexto, 'CstmrCdtTrfInitn');
         --GETXMLTYPE...
         xmldocv := DBMS_XMLGEN.getxml(contexto, DBMS_XMLGEN.NONE);
         xmldocv := REPLACE( xmldocv, '<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>' );
         DBMS_XMLGEN.closecontext(contexto);
         --Insertamos el xml inicial y lo vamos completando
         v_finsert := f_sysdate;

         INSERT INTO xml_transferencias
                     (id_transferencias, fecha, xmldoc)
              VALUES (pidtransf, v_finsert, XMLTYPE(xmldocv));

              --AGG no lo inserto porque hay problemas con el nombre xmlns:xsi por ":" no se como introducirlo
         /*     update xml_domiciliaciones
              set xmldoc = insertchildxml(xmldoc, '/Document', '@xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
              WHERE id_domici = piddomisepa;*/
         BEGIN
            UPDATE xml_transferencias
               SET xmldoc = INSERTCHILDXML(xmldoc, '/Document', '@xmlns',
                                           'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03')
             WHERE id_transferencias = pidtransf
               AND fecha = v_finsert;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         UPDATE xml_transferencias
            SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '/Document/CstmrCdtTrfInitn',
                       (SELECT XMLELEMENT
                                  ("GrpHdr", XMLELEMENT("MsgId", s.msgid),
                                   XMLELEMENT("CreDtTm",
                                              REPLACE(TO_CHAR(s.credttm,
                                                              'YYYY-MM-DD HH24:MI:SS'),
                                                      ' ', 'T')),
                                   XMLELEMENT("NbOfTxs", s.nboftxs),
                                   XMLELEMENT
                                      ("CtrlSum",
                                       LTRIM
                                          (RTRIM(REPLACE(TO_CHAR(s.ctrlsum,
                                                                 '999999999999990.00'),
                                                         ',', '.')))   --REPLACE(s.ctrlsum, ',', '.')
                                                                    ))
                          FROM remesas_sepa s
                         WHERE s.idremesassepa = pidtransf))
          WHERE id_transferencias = pidtransf;

         --INICIO 40690 DCT 14/04/2016
         --Comentamos el update y lo hacemos mas abajo en el FOR de remesas_sepa_pago
         --agg fin nuevo
         /*UPDATE xml_transferencias
            SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '//CstmrCdtTrfInitn/GrpHdr',
                       (SELECT XMLELEMENT
                                     ("InitgPty",
                                      XMLELEMENT("Nm", f_caracteres_sepa(r.initgpty_nm_3)),
                                      XMLELEMENT("Id",
                                                 XMLELEMENT("OrgId",
                                                            XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  othr_id_6)))))
                          FROM remesas_sepa r
                         WHERE r.idremesassepa = pidtransf))
          WHERE id_transferencias = pidtransf;*/
          --INICIO 40690 DCT 14/04/2016

         FOR reg IN (SELECT *
                       FROM remesas_sepa_pago
                      WHERE idremesasepa = pidtransf) LOOP
           --INICIO 40690 DCT 14/04/2016
           IF v_bicorbei = 0 THEN
             --NO AGM
             UPDATE xml_transferencias
              SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '//CstmrCdtTrfInitn/GrpHdr',
                       (SELECT XMLELEMENT
                                     ("InitgPty",
                                      XMLELEMENT("Nm", f_caracteres_sepa(r.initgpty_nm_3)),
                                      XMLELEMENT("Id",
                                                 XMLELEMENT("OrgId",
                                                            XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  othr_id_6)))))
                          FROM remesas_sepa r
                         WHERE r.idremesassepa = pidtransf))
                WHERE id_transferencias = pidtransf;
          ELSE
            --Para AGM
            --Debemos mostrar el nif de la empresa con el numerador: othr_id_6
			v_numremesa:=v_numremesa+1; -- BUG 0040690 - 26/04/16 - EDA
			SELECT r.othr_id_6 ||LPAD(v_numremesa, 3, 0)
			  INTO vothr_id_6
        FROM remesas_sepa r
       WHERE r.idremesassepa = pidtransf;

            UPDATE xml_transferencias
              SET xmldoc =
                   APPENDCHILDXML
                      (xmldoc, '//CstmrCdtTrfInitn/GrpHdr',
                       (SELECT XMLELEMENT
                                     ("InitgPty",
                                      XMLELEMENT("Nm", f_caracteres_sepa(r.initgpty_nm_3)),
                                      XMLELEMENT("Id",
                                                 XMLELEMENT("OrgId",
                                                            XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                   vothr_id_6 ))))) -- BUG 0040690 - 26/04/16 - EDA
                          FROM remesas_sepa r
                         WHERE r.idremesassepa = pidtransf))
            WHERE id_transferencias = pidtransf;
          END IF;
          --FIN 40690 DCT 14/04/2016


            v_idpago := reg.idpago;
            --Tabla remesas_sepa_pago
            contexto :=
               DBMS_XMLGEN.newcontext
                  ('select pmtinfid "PmtInfId", pmtmtd "PmtMtd", btchbookg "BtchBookg", nboftxs "NbOfTxs",
                  LTRIM(RTRIM(REPLACE(TO_CHAR(ctrlsum,''999999999999990.00''), '','', ''.''))) "CtrlSum"
                  from remesas_sepa_pago d where idremesasepa='
                   || pidtransf || ' and idpago=' || v_idpago);
            --Root message TEMPORAL
            DBMS_XMLGEN.setrowsettag(contexto, 'ROOT_TBL_PAGOS');
            --Header
            DBMS_XMLGEN.setrowtag(contexto, 'PmtInf');
            --GETXMLTYPE...
            xmldocv := DBMS_XMLGEN.getxml(contexto, DBMS_XMLGEN.NONE);
            DBMS_XMLGEN.closecontext(contexto);

            --Añadimos los tags DIRECTOS de la tabla REMESAS_SEPA_PAGO
            UPDATE xml_transferencias
               SET xmldoc = APPENDCHILDXML(xmldoc, '//CstmrCdtTrfInitn',
                                           EXTRACT(XMLTYPE(xmldocv), '/ROOT_TBL_PAGOS/PmtInf'))
             WHERE id_transferencias = pidtransf;

            --transformamos los tags INDIRECTOS de la tabla REMESAS_SEPA_PAGO
          BEGIN
            IF v_version > '11.2.0.2.0' THEN


              --INICIO 40690 DCT 14/04/2016
              IF v_bicorbei = 0 THEN
                --Se utiliza el Tag <BICOrBEI>
                UPDATE xml_transferencias
                  SET xmldoc =
                         APPENDCHILDXML
                            (xmldoc,
                             '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                             (SELECT XMLELEMENT("PmtTpInf",
                                                (XMLELEMENT("SvcLvl",
                                                            (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                     || XMLELEMENT("ReqdExctnDt",
                                                   TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                     || XMLELEMENT
                                          ("Dbtr",
                                           XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                           (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT("OrgId",
                                                               (XMLELEMENT("BICOrBEI",
                                                                           p.orgid_bicorbei_5)))))))
                                     || XMLELEMENT("DbtrAcct",
                                                   (XMLELEMENT("Id",
                                                               (XMLELEMENT("IBAN", p.id_iban_4)))))
                                     -- ini BUG 0036701 - 02/07/15 - JMF
                                     || XMLELEMENT
                                                  ("DbtrAgt",
                                                   (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                       decode(p.fininstnid_bic_4,null,null,
                                                                               (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                             )
                                                                          ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                     -- fin BUG 0036701 - 02/07/15 - JMF
                                FROM remesas_sepa_pago p
                               WHERE p.idremesasepa = pidtransf
                                 AND idpago = v_idpago)
                                                       --,  'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"' v10
                                                                     --ORDER by P.idpago)
                         )
                       WHERE id_transferencias = pidtransf;
               ELSE
                 --NO Utilizamos el Tag <BICOrBEI>
                    UPDATE xml_transferencias
                  SET xmldoc =
                         APPENDCHILDXML
                            (xmldoc,
                             '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                             (SELECT XMLELEMENT("PmtTpInf",
                                                (XMLELEMENT("SvcLvl",
                                                            (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                     || XMLELEMENT("ReqdExctnDt",
                                                   TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                     || XMLELEMENT
                                          ("Dbtr",
                                           XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                           (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT("OrgId",
                                                               XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  vothr_id_6))))))) -- BUG 0040690 - 26/04/16 - EDA
                                     || XMLELEMENT("DbtrAcct",
                                                   (XMLELEMENT("Id",
                                                               (XMLELEMENT("IBAN", p.id_iban_4)))))
                                     -- ini BUG 0036701 - 02/07/15 - JMF
                                     || XMLELEMENT
                                                  ("DbtrAgt",
                                                   (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                       decode(p.fininstnid_bic_4,null,null,
                                                                               (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                             )
                                                                          ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                     -- fin BUG 0036701 - 02/07/15 - JMF
                                FROM remesas_sepa_pago p
                               WHERE p.idremesasepa = pidtransf
                                 AND idpago = v_idpago)
                                                       --,  'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"' v10
                                                                     --ORDER by P.idpago)
                         )
                       WHERE id_transferencias = pidtransf;
               END IF;
               --FIN 40690 DCT 14/04/2016

            ELSE
              BEGIN
                --Miramos si existe el salto de línea (LA SELECT devuelve valor pero no actualiza el XMLTYPE!!!!...es como si no fuera XML..devuelve texto sin saltos de línea!!!)

                SELECT (extract (xmldoc,'//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]')).getclobval()
                --,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval() (NO LO ENTIENDO --> SIN NAMESPACE!!!)
                  INTO xmldocv
                  FROM xml_transferencias x
                 WHERE id_transferencias= pidtransf ;
                  --and instr((extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]'
                  --             ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval(),chr(10)) <> 0;

                 IF INSTR(xmldocv, CHR(10)) = 0 THEN
                    RAISE NO_DATA_FOUND;   --update sin indice en array
                 END IF;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN

                   --INICIO 40690 DCT 14/04/2016
                   IF v_bicorbei = 0 THEN
                     --Se utliza el Tag <BICOrBEI>
                     --Si no encuentra saltos de línea en el XML, el XML devuelto no sirve, es más texto que XML (por eso controlo el salto de línea)
                     --(NO SE XQ no funciona XPATH con indice correctamente y no hace el UPDATE!!!!). Este UPDATE es diferente!!!
                     UPDATE xml_transferencias
                       SET xmldoc =
                             APPENDCHILDXML
                                (xmldoc,
                                 '//CstmrCdtTrfInitn/PmtInf',
                                 (SELECT XMLELEMENT("PmtTpInf",
                                                    (XMLELEMENT("SvcLvl",
                                                                (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                         || XMLELEMENT("ReqdExctnDt",
                                                       TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                         || XMLELEMENT
                                              ("Dbtr",
                                               XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                               (XMLELEMENT
                                                      ("Id",
                                                       (XMLELEMENT("OrgId",
                                                                   (XMLELEMENT("BICOrBEI",
                                                                               p.orgid_bicorbei_5)))))))
                                         || XMLELEMENT("DbtrAcct",
                                                       (XMLELEMENT("Id",
                                                                   (XMLELEMENT("IBAN", p.id_iban_4)))))
                                         -- ini BUG 0036701 - 02/07/15 - JMF
                                         || XMLELEMENT
                                                      ("DbtrAgt",
                                                       (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                           decode(p.fininstnid_bic_4,null,null,
                                                                                   (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                                 )
                                                                              ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                        -- fin BUG 0036701 - 02/07/15 - JMF
                                    FROM remesas_sepa_pago p
                                   WHERE p.idremesasepa = pidtransf
                                     AND idpago = v_idpago)
                                -- ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                                                                         --ORDER by P.idpago)
                             )
                    WHERE id_transferencias = pidtransf;
                  ELSE
                    --NO Utilizamos el Tag <BICOrBEI>
                    UPDATE xml_transferencias
                       SET xmldoc =
                             APPENDCHILDXML
                                (xmldoc,
                                 '//CstmrCdtTrfInitn/PmtInf',
                                 (SELECT XMLELEMENT("PmtTpInf",
                                                    (XMLELEMENT("SvcLvl",
                                                                (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                         || XMLELEMENT("ReqdExctnDt",
                                                       TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                         || XMLELEMENT
                                              ("Dbtr",
                                               XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                               (XMLELEMENT
                                                      ("Id",
                                                       (XMLELEMENT("OrgId",
                                                          XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  vothr_id_6)))))))    -- BUG 0040690 - 26/04/16 - EDA
                                         || XMLELEMENT("DbtrAcct",
                                                       (XMLELEMENT("Id",
                                                                   (XMLELEMENT("IBAN", p.id_iban_4)))))
                                         -- ini BUG 0036701 - 02/07/15 - JMF
                                         || XMLELEMENT
                                                      ("DbtrAgt",
                                                       (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                           decode(p.fininstnid_bic_4,null,null,
                                                                                   (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                                 )
                                                                              ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                         -- fin BUG 0036701 - 02/07/15 - JMF
                                    FROM remesas_sepa_pago p
                                   WHERE p.idremesasepa = pidtransf
                                     AND idpago = v_idpago)
                                -- ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                                                                         --ORDER by P.idpago)
                             )
                    WHERE id_transferencias = pidtransf;


                  END IF;
                  --FIN 40690 DCT 14/04/2016

                    RAISE update_sin_array;   --CONTINUE
              END;

              --INICIO 40690 DCT 14/04/2016
              IF v_bicorbei = 0 THEN
                --Si se utiliza el tag BICOrBEI
                UPDATE xml_transferencias
                  SET xmldoc =
                         APPENDCHILDXML
                            (xmldoc,
                             '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                             (SELECT XMLELEMENT("PmtTpInf",
                                                (XMLELEMENT("SvcLvl",
                                                            (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                     || XMLELEMENT("ReqdExctnDt",
                                                   TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                     || XMLELEMENT
                                          ("Dbtr",
                                           XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                           (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT("OrgId",
                                                               (XMLELEMENT("BICOrBEI",
                                                                           p.orgid_bicorbei_5)))))))
                                     || XMLELEMENT("DbtrAcct",
                                                   (XMLELEMENT("Id",
                                                               (XMLELEMENT("IBAN", p.id_iban_4)))))
                                     -- ini BUG 0036701 - 02/07/15 - JMF
                                     || XMLELEMENT
                                                  ("DbtrAgt",
                                                   (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                       decode(p.fininstnid_bic_4,null,null,
                                                                               (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                             )
                                                                          ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                     -- fin BUG 0036701 - 02/07/15 - JMF
                                FROM remesas_sepa_pago p
                               WHERE p.idremesasepa = pidtransf
                                 AND idpago = v_idpago),
                             'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                                                                     --ORDER by P.idpago)
                         )
               WHERE id_transferencias = pidtransf;
           ELSE
              --NO Utilizamos el Tag <BICOrBEI>
              UPDATE xml_transferencias
                  SET xmldoc =
                         APPENDCHILDXML
                            (xmldoc,
                             '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                             (SELECT XMLELEMENT("PmtTpInf",
                                                (XMLELEMENT("SvcLvl",
                                                            (XMLELEMENT("Cd", p.svclvl_cd_4)))))
                                     || XMLELEMENT("ReqdExctnDt",
                                                   TO_CHAR(reqdexctndt, 'YYYY-MM-DD'))
                                     || XMLELEMENT
                                          ("Dbtr",
                                           XMLELEMENT("Nm", f_caracteres_sepa(p.dbtr_nm_3)),
                                           (XMLELEMENT
                                                  ("Id",
                                                   (XMLELEMENT("OrgId",

                                                                XMLELEMENT("Othr",
                                                                       XMLELEMENT("Id",
                                                                                  vothr_id_6)) )))))  -- BUG 0040690 - 26/04/16 - EDA
                                     || XMLELEMENT("DbtrAcct",
                                                   (XMLELEMENT("Id",
                                                               (XMLELEMENT("IBAN", p.id_iban_4)))))
                                     -- ini BUG 0036701 - 02/07/15 - JMF
                                     || XMLELEMENT
                                                  ("DbtrAgt",
                                                   (XMLELEMENT("FinInstnId", decode(v_bic,1,
                                                                       decode(p.fininstnid_bic_4,null,null,
                                                                               (XMLELEMENT("BIC",p.fininstnid_bic_4))
                                                                             )
                                                                          ,(XMLELEMENT("BIC",p.fininstnid_bic_4))))))
                                     -- fin BUG 0036701 - 02/07/15 - JMF
                                FROM remesas_sepa_pago p
                               WHERE p.idremesasepa = pidtransf
                                 AND idpago = v_idpago),
                             'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                                                                     --ORDER by P.idpago)
                         )
               WHERE id_transferencias = pidtransf;
            END IF;
            --FIN 40690 DCT 14/04/2016

           END IF;
          EXCEPTION
               WHEN update_sin_array THEN
                  NULL;   --continue
               WHEN OTHERS THEN
                  NULL;
          END;

            FOR regdet IN (SELECT *
                             FROM remesas_sepa_pago_det
                            WHERE idremesasepa = pidtransf) LOOP
               v_iddetalle := regdet.iddetalle;


             BEGIN
               --Tabla remesas_sepa_pago_det (todos los TAGS son INDIRECTOS --> se deben calcular según su .XSD relacionado)
               IF v_version > '11.2.0.2.0' THEN
                  UPDATE xml_transferencias
                     SET xmldoc =
                            APPENDCHILDXML
                               (xmldoc,
                                '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                                (SELECT XMLELEMENT
                                           ("CdtTrfTxInf",
                                            XMLELEMENT("PmtId",
                                                       XMLELEMENT("InstrId",
                                                                  d.pmtid_instrid_4),
                                                       XMLELEMENT("EndToEndId",
                                                                  d.instrid_endtoendid_4)),
                                            XMLELEMENT
                                               ("Amt",
                                                XMLELEMENT
                                                   ("InstdAmt", xmlattributes('EUR' AS "Ccy"),
                                                    LTRIM
                                                       (RTRIM
                                                           (REPLACE
                                                                (TO_CHAR(d.amt_instdamt_4,
                                                                         '999999999999990.00'),
                                                                 ',', '.')))   --REPLACE(d.amt_instdamt_4, ',', '.')
                                                                            )),
                                            -- ini BUG 0036701 - 02/07/15 - JMF
                                            -- Inicio  0041958 - 28/04/16 - EDA
                                            XMLELEMENT
                                                    ("CdtrAgt",
                                                     XMLELEMENT("FinInstnId",
                                                         decode(v_bic_alwz,1,null,(decode(v_bic,1,
                                                                decode(d.fininstnid_bic_5,null,null,
                                                                         XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                      )
                                                                ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                            -- Fin  0041958 - 28/04/16 - EDA
                                            -- fin BUG 0036701 - 02/07/15 - JMF
                                            XMLELEMENT
                                                    ("Cdtr",
                                                     XMLELEMENT("Nm",
                                                                f_caracteres_sepa(d.cdtr_nm_4))),
                                            XMLELEMENT
                                               ("CdtrAcct",
                                                XMLELEMENT
                                                   ("Id",
                                                    XMLELEMENT
                                                       ("IBAN", d.id_iban_5)   --IBAN en lugar de Othr/Id s/CIV

                                                                            --      XMLELEMENT("Othr", XMLELEMENT("Id", d.othr_id_6))
                                                )),
                                            DECODE (pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP'),
                                            NULL, NULL, XMLELEMENT
                                               ("Purp",
                                                XMLELEMENT
                                                   ("Cd", pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP')))
                                                ),
                                            XMLELEMENT
                                               ("RmtInf",
                                                XMLELEMENT("Ustrd",
                                                           f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                           )))
                                   FROM remesas_sepa_pago_det d
                                  WHERE d.idremesasepa = pidtransf
                                    AND d.idpago = v_idpago
                                    AND d.iddetalle = v_iddetalle)
                                                                  --,  'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"' v10
                            )
                   WHERE id_transferencias = pidtransf;
               ELSE
                  BEGIN
                    --Miramos si existe el salto de línea (LA SELECT devuelve valor pero no actualiza el XMLTYPE!!!!...es como si no fuera XML..devuelve texto sin saltos de línea!!!)

                    SELECT (extract (xmldoc,'//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]')).getclobval()
                    --,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval() (NO LO ENTIENDO --> SIN NAMESPACE!!!)
                      INTO xmldocv
                      FROM xml_transferencias x
                     WHERE id_transferencias= pidtransf ;
                      --and instr((extract (xmldoc,'//CstmrDrctDbtInitn/PmtInf[PmtInfId="' || v_idpago || '"]'
                      --             ,'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')).getclobval(),chr(10)) <> 0;

                     IF INSTR(xmldocv, CHR(10)) = 0 THEN
                        RAISE NO_DATA_FOUND;   --update sin indice en array
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        --Si no encuentra saltos de línea en el XML, el XML devuelto no sirve, es más texto que XML (por eso controlo el salto de línea)
                        --(NO SE XQ no funciona XPATH con indice correctamente y no hace el UPDATE!!!!). Este UPDATE es diferente!!!
                          UPDATE xml_transferencias
                             SET xmldoc = APPENDCHILDXML (xmldoc, '//CstmrCdtTrfInitn/PmtInf',
                                        (SELECT XMLELEMENT
                                                   ("CdtTrfTxInf",
                                                    XMLELEMENT("PmtId",
                                                               XMLELEMENT("InstrId",
                                                                          d.pmtid_instrid_4),
                                                               XMLELEMENT("EndToEndId",
                                                                          d.instrid_endtoendid_4)),
                                                    XMLELEMENT
                                                       ("Amt",
                                                        XMLELEMENT
                                                           ("InstdAmt", xmlattributes('EUR' AS "Ccy"),
                                                            LTRIM
                                                               (RTRIM
                                                                   (REPLACE
                                                                        (TO_CHAR(d.amt_instdamt_4,
                                                                                 '999999999999990.00'),
                                                                         ',', '.')))   --REPLACE(d.amt_instdamt_4, ',', '.')
                                                                                    )),
                                                    -- ini BUG 0036701 - 02/07/15 - JMF
                                                    -- Inicio  0041958 - 28/04/16 - EDA
                                                    XMLELEMENT
                                                            ("CdtrAgt",
                                                             XMLELEMENT("FinInstnId",
                                                                 decode(v_bic_alwz,1,null,(decode(v_bic,1,
                                                                        decode(d.fininstnid_bic_5,null,null,
                                                                                 XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                              )
                                                                        ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                                    -- Fin  0041958 - 28/04/16 - EDA
                                                    -- fin BUG 0036701 - 02/07/15 - JMF
                                                    XMLELEMENT
                                                            ("Cdtr",
                                                             XMLELEMENT("Nm",
                                                                        f_caracteres_sepa(d.cdtr_nm_4))),
                                                    XMLELEMENT
                                                       ("CdtrAcct",
                                                        XMLELEMENT
                                                           ("Id",
                                                            XMLELEMENT
                                                               ("IBAN", d.id_iban_5)   --IBAN en lugar de Othr/Id s/CIV

                                                                                    --      XMLELEMENT("Othr", XMLELEMENT("Id", d.othr_id_6))
                                                        )),
                                            DECODE (pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP'),
                                            NULL, NULL, XMLELEMENT
                                               ("Purp",
                                                XMLELEMENT
                                                   ("Cd", pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP')))
                                                ),
                                                    XMLELEMENT
                                                       ("RmtInf",
                                                        XMLELEMENT("Ustrd",
                                                                   f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                                   )))
                                           FROM remesas_sepa_pago_det d
                                          WHERE d.idremesasepa = pidtransf
                                            AND d.idpago = v_idpago
                                            AND d.iddetalle = v_iddetalle)
                                       --, 'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"'
                                       )
                           WHERE id_transferencias = pidtransf;

                        RAISE update_sin_array;   --CONTINUE
                  END;

                  UPDATE xml_transferencias
                     SET xmldoc =
                            APPENDCHILDXML
                               (xmldoc,
                                '//CstmrCdtTrfInitn/PmtInf[PmtInfId="' || reg.pmtinfid || '"]',
                                (SELECT XMLELEMENT
                                           ("CdtTrfTxInf",
                                            XMLELEMENT("PmtId",
                                                       XMLELEMENT("EndToEndId",
                                                                  d.instrid_endtoendid_4)),
                                            XMLELEMENT
                                               ("Amt",
                                                XMLELEMENT
                                                   ("InstdAmt", xmlattributes('EUR' AS "Ccy"),
                                                    LTRIM
                                                       (RTRIM
                                                           (REPLACE
                                                                (TO_CHAR(d.amt_instdamt_4,
                                                                         '999999999999990.00'),
                                                                 ',', '.')))   --REPLACE(d.amt_instdamt_4, ',', '.')
                                                                            )),
                                            -- ini BUG 0036701 - 02/07/15 - JMF
                                            -- Inicio  0041958 - 28/04/16 - EDA
                                            XMLELEMENT
                                                    ("CdtrAgt",
                                                     XMLELEMENT("FinInstnId",
                                                         decode(v_bic_alwz,1,null,(decode(v_bic,1,
                                                                decode(d.fininstnid_bic_5,null,null,
                                                                         XMLELEMENT("BIC",d.fininstnid_bic_5)
                                                                      )
                                                                ,XMLELEMENT("BIC",d.fininstnid_bic_5)))))),
                                            -- Fin  0041958 - 28/04/16 - EDA
                                            -- fin BUG 0036701 - 02/07/15 - JMF
                                            XMLELEMENT
                                                    ("Cdtr",
                                                     XMLELEMENT("Nm",
                                                                f_caracteres_sepa(d.cdtr_nm_4))),
                                            XMLELEMENT
                                               ("CdtrAcct",
                                                XMLELEMENT
                                                   ("Id",
                                                    XMLELEMENT
                                                       ("IBAN", d.id_iban_5)   --IBAN en lugar de Othr/Id s/CIV

                                                                            --      XMLELEMENT("Othr", XMLELEMENT("Id", d.othr_id_6))
                                                )),
                                            DECODE (pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP'),
                                            NULL, NULL, XMLELEMENT
                                               ("Purp",
                                                XMLELEMENT
                                                   ("Cd", pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,'SEPA_TAG_PURP')))
                                                ),
                                            XMLELEMENT
                                               ("RmtInf",
                                                XMLELEMENT("Ustrd",
                                                           f_caracteres_sepa(d.rmtinf_ustrd_4)
                                                           )))
                                   FROM remesas_sepa_pago_det d
                                  WHERE d.idremesasepa = pidtransf
                                    AND d.idpago = v_idpago
                                    AND d.iddetalle = v_iddetalle),
                                'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.02"')
                   WHERE id_transferencias = pidtransf;
               END IF;
             EXCEPTION
             WHEN update_sin_array THEN
                  NULL;   --continue
             WHEN OTHERS THEN
                  NULL;
             END;

            END LOOP;
         END LOOP;
/*
         UPDATE xml_transferencias x
            SET x.xmldoc = XMLTYPE(f_caracteres_sepa(x.xmldoc.getclobval()))
          WHERE x.id_transferencias = pidtransf;
*/
      END IF;

      RETURN 0;
   END f_genera_xml_transferencias;

  FUNCTION f_genera_fichero_dom_trans(
      pmodaldomtrans IN VARCHAR2,
      pid IN NUMBER,
      pnombrefichero IN VARCHAR2)
      RETURN NUMBER IS
      --var_xml_domic  VARCHAR2(2000);
      var_xml_domic  CLOB;
      cont           NUMBER := 0;
      inici_tram     NUMBER;
      fi_tram        NUMBER;
      posicions      NUMBER;
      v_fitxer       UTL_FILE.file_type;
      xml_domic      CLOB;
      v_vobject      VARCHAR2(50) := 'f_genera_fichero_dom_trans';
      v_ntraza       NUMBER := 1;

      v_xmldata      XMLTYPE;
      v_exten VARCHAR2(10 byte);
    BEGIN
       -- 35341.NMM
       SELECT XMLROOT( XMLType(oxml.xmldoc.getClobval()) , version '1.0" encoding="UTF-8')
         INTO v_xmldata
         FROM (SELECT xmldoc
                FROM xml_domiciliaciones
               WHERE id_domici = pid
                 AND pmodaldomtrans = 'D'
              UNION ALL
              SELECT xmldoc
                FROM xml_transferencias
               WHERE id_transferencias = pid
                 AND pmodaldomtrans = 'T')oxml;

        xml_domic := v_xmldata.getClobVal(); --> Convertir de XML a CLOB
--       xml_domic := REPLACE( xml_domic, '<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>' );


      --dbms_xslprocessor.clob2file(l_xml.getclobval(),'TEMP','emp.xml',nls_charset_id('UTF8'));

        BEGIN
           SELECT c.transf_file_ext
             INTO v_exten
             FROM remesas_sepa rs, remesas r, cobbancario c
            WHERE rs.idremesassepa = pid
              AND r.nremesa = rs.msgid
              AND c.ccobban = r.ccobban
              AND ROWNUM = 1;
        EXCEPTION
           WHEN OTHERS THEN
              v_exten := NULL;
        END;

       v_exten := NVL(v_exten, 'xml');

       DBMS_XSLPROCESSOR.clob2file (xml_domic,'UTLDIR',pnombrefichero || '.' || v_exten ,nls_charset_id('UTF8'));--> Convertir de CLOB a FILE en disco

      UTL_FILE.fclose(v_fitxer);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(v_fitxer) THEN
            UTL_FILE.fclose(v_fitxer);
         END IF;

         p_tab_error(f_sysdate, f_user, v_vobject, v_ntraza, 'Error sqlcode=' || SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_genera_fichero_dom_trans;

   --AGG modificaciones SEPA
   /*Función que devuelve el mandato correspondiente a un seguro y a un ccobban*/
   FUNCTION f_get_mandatos(
      psseguro IN seguros.sseguro%TYPE,
      pccobban IN cobbancario.ccobban%TYPE,
      pcbancar IN recibos.cbancar%TYPE,
      pctipban IN recibos.ctipban%TYPE)
      RETURN mandatos%ROWTYPE IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro =' || psseguro || ' pccobban =' || pccobban || 'pcbancar =' || pcbancar
            || ' pctipban =' || pctipban;
      vcexistepagador NUMBER;
      vsperson       tomadores.sperson%TYPE;
      vctipcc        tipos_cuenta.ctipcc%TYPE;
      rmandatos      mandatos%ROWTYPE;
      error          NUMBER;
      e_salida       EXCEPTION;
   BEGIN
      /*BEGIN
         SELECT NVL(t.cexistepagador, 0), sperson
           INTO vcexistepagador, vsperson
           FROM tomadores t
          WHERE t.sseguro = psseguro
            AND t.nordtom = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --error := 105111; -- Tomador no encontrado en la tabla TOMADORES.
            RAISE e_salida;
         WHEN OTHERS THEN
            --error := 105112; -- Error al leer de la tabla TOMADORES.
            RAISE e_salida;
      END;

      vpasexec := 2;

      IF vcexistepagador = 1 THEN
         BEGIN
            SELECT g.sperson
              INTO vsperson
              FROM gescobros g
             WHERE g.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --error := 9904082; -- Gestor de cobro / Pagador no encontrado en la tabla GESCOBROS.
               RAISE e_salida;
            WHEN OTHERS THEN
               RAISE e_salida;
         END;
      END IF;*/
      BEGIN
         SELECT NVL(r.sperson, t.sperson)
           INTO vsperson
           FROM recibos r, tomadores t
          WHERE r.sseguro = psseguro
            AND r.sseguro = t.sseguro
            AND ROWNUM = 1;
      END;

      vpasexec := 3;

      --INICIO DCT 40784 AGM - 40784
      BEGIN
         SELECT *
           INTO rmandatos
           FROM mandatos
          WHERE sperson = vsperson
            AND ctipban = pctipban
            AND cbancar = pcbancar
            AND ccobban = pccobban
            AND(sseguro = psseguro
                OR psseguro IS NULL);
      EXCEPTION
         WHEN OTHERS THEN
          BEGIN
            SELECT *
              INTO rmandatos
              FROM mandatos
              WHERE sperson = vsperson
                AND ctipban = pctipban
                AND cbancar = pcbancar
                AND(sseguro = psseguro
                OR psseguro IS NULL);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
      END;
      --FIN DCT 40784 AGM - 40784

      RETURN rmandatos;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.f_get_mandatos', vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_mandatos;

   --AGG modificaciones SEPA
   /*******************************************************************************
   FUNCION f_set_mandatos
         -- Descripcion
   Parámetros:
    Entrada :
      psseguro: Número de seguro - Obligatorio
      pnrecibo: Número de recibo - Opcional - Se informa cuando queremos controlarlo por RECIBO
      pcestado: Código de estado - Opcional - Solo informalo para forzar un estado en concreto.
      -- Los siguientes parámetros solo se informan desde el trigger de RECIBOS AIU_RECIBOS_SEPA,
      -- para evitar tener que hacer SELECT sobre recibos, y evitar el error que dice que la tabla está mutando.
      psperson: Identificador de la persona  - Opcional
      pcbancar: Cuenta bancaria - Opcional
      pctipban: Tipo cuenta bancaria - Opcional
      pccobban: Código de cobrador bancario - Opcional

     Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
   ********************************************************************************/
   FUNCTION f_set_mandatos(
      psseguro IN recibos.sseguro%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE DEFAULT NULL,
      pcestado IN mandatos.cestado%TYPE DEFAULT NULL,
      psperson IN recibos.sperson%TYPE DEFAULT NULL,
      pcbancar IN recibos.cbancar%TYPE DEFAULT NULL,
      pctipban IN recibos.ctipban%TYPE DEFAULT NULL,
      pccobban IN recibos.ctipban%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vctipban       NUMBER(3) := 0;
      vccobban       NUMBER(3) := 0;
      vcbancar       VARCHAR2(50);
      vpasexec       NUMBER(8) := 1;
      vcmandato      VARCHAR2(35);
      vcestado       NUMBER;
      vsperson       per_ccc.sperson%TYPE := psperson;
      vcnordban      per_ccc.cnordban%TYPE;
      vparam         VARCHAR2(200)
         := 'psseguro =' || psseguro || ' pnrecibo =' || pnrecibo || ' pcestado: ' || pcestado;
   BEGIN
      vpasexec := 10;
      vcestado := pcestado;

      -- Estado del mandato 0-Desactivado, 1-Activado, 2-Cancelado
      IF vcestado IS NULL THEN
         vpasexec := 20;
         vcestado := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                       'MANDATO_DEFECTO'),
                         0);
      END IF;

      vpasexec := 30;

      IF pcbancar IS NULL
         OR pctipban IS NULL
         OR pccobban IS NULL THEN
         IF pnrecibo IS NOT NULL THEN
            vpasexec := 50;

            SELECT cbancar, ctipban, ccobban, sperson
              INTO vcbancar, vctipban, vccobban, vsperson
              FROM recibos
             WHERE nrecibo = pnrecibo;
         ELSE
            vpasexec := 60;

            SELECT cbancar, ctipban, ccobban
              INTO vcbancar, vctipban, vccobban
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      ELSE
         vpasexec := 70;
         vcbancar := pcbancar;
         vctipban := pctipban;
         vccobban := pccobban;
      END IF;

      vpasexec := 80;

      IF vsperson IS NULL THEN
         vpasexec := 30;
         vsperson := ff_sperson_tomador(psseguro);
      END IF;

      vpasexec := 90;

      SELECT MAX(cnordban)
        INTO vcnordban
        FROM per_ccc
       WHERE sperson = vsperson
         AND cbancar = vcbancar
         AND ctipban = vctipban;

      vpasexec := 90;

      IF vcnordban IS NOT NULL THEN
         --mandatos
         vpasexec := 100;
         vcmandato := LPAD(NVL(psseguro, '0'), 6, '0') || LPAD(vccobban, 3, '0')
                      || LPAD(vsperson, 10, '0') || LPAD(vcnordban, 3, '0');
         vpasexec := 110;

         INSERT INTO mandatos
                     (sperson, cnordban, ctipban, cbancar, ccobban, sseguro, cmandato,
                      cestado, ffirma, fusualta, cusualta)
              VALUES (vsperson, vcnordban, vctipban, vcbancar, vccobban, psseguro, vcmandato,
                      vcestado, f_sysdate, f_sysdate, pac_md_common.f_get_cxtusuario());
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_domis.f_set_mandatos', vpasexec, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_set_mandatos;

   /*******************************************************************************
    FUNCION f_caracteres_sepa

    Convierte un texto al estándar SEPA, eliminando los no soportados por SEPA y sustituyendo los
    no permitidos por en XML.

    Las características y contenido del mensaje deberán ajustarse a las reglas del esquema de adeudos
    directos SEPA. En el mismo se definen, entre otras reglas, los caracteres admitidos, que se ajustarán
    a los siguientes:

    Entrada: ptexto --> Texto a convertir
    Salida : vtexto --> Texto convertido

   *******************************************************************************/
   FUNCTION f_caracteres_sepa(ptexto IN VARCHAR2)
      RETURN VARCHAR2 IS
      vletra         VARCHAR2(1);
      vtexto         VARCHAR2(9000);
      vpasexec       NUMBER;
   BEGIN
      vpasexec := 10;

      FOR i IN 1 .. LENGTH(ptexto) LOOP
         vpasexec := 20;
         vletra := SUBSTR(ptexto, i, 1);
         vpasexec := 30;

         IF vletra IN('A',
                      'B',
                      'C',
                      'D',
                      'E',
                      'F',
                      'G',
                      'H',
                      'I',
                      'J',
                      'K',
                      'L',
                      'M',
                      'N',
                      'O',
                      'P',
                      'Q',
                      'R',
                      'S',
                      'T',
                      'U',
                      'V',
                      'W',
                      'X',
                      'Y',
                      'Z',
                      'a',
                      'b',
                      'c',
                      'd',
                      'e',
                      'f',
                      'g',
                      'h',
                      'i',
                      'j',
                      'k',
                      'l',
                      'm',
                      'n',
                      'o',
                      'p',
                      'q',
                      'r',
                      's',
                      't',
                      'u',
                      'v',
                      'w',
                      'x',
                      'y',
                      'z',
                      '0',
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '/',
                      '-',
                      '?',
                      ':',
                      '(',
                      ')',
                      '.',
                      ',',
                      '‘',
                      '+',
                      ' ',
                      '&',
                      '<',
                      '>',
                      '"',
                      CHR(39),
                      'Ñ',
                      'ñ',
                      'Ç',
                      'ç') THEN
            vpasexec := 40;
            vtexto := vtexto || vletra;
         END IF;
      END LOOP;

-- BUG 0038100 - 13/10/15 - JMF
-- Problemas con caracteres especiales
/*
      vpasexec := 50;
      vtexto := REPLACE(vtexto, '&', '&' || 'amp;');   -- (ampersand)
      vpasexec := 60;
      vtexto := REPLACE(vtexto, '<', '&' || 'lt;');   -- (menor que)
      vpasexec := 70;
      vtexto := REPLACE(vtexto, '>', '&' || 'gt;');   -- (mayor que)
      vpasexec := 80;
      vtexto := REPLACE(vtexto, '"', '&' || 'quot;');   -- (dobles comillas)
      vpasexec := 90;
      vtexto := REPLACE(vtexto, CHR(39), '&' || 'apos;');   -- (apóstrofe)
*/
      vpasexec := 100;
      vtexto := REPLACE(vtexto, 'Ñ', 'N');
      vpasexec := 110;
      vtexto := REPLACE(vtexto, 'ñ', 'n');
      vpasexec := 120;
      vtexto := REPLACE(vtexto, 'Ç', 'C');
      vpasexec := 130;
      vtexto := REPLACE(vtexto, 'ç', 'c');
      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SEPA.f_caracteres_sepa', vpasexec, SQLERRM,
                     SUBSTR(ptexto, 1, 2500));
         RETURN NULL;
   END f_caracteres_sepa;
END pac_sepa;

/

  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SEPA" TO "PROGRAMADORESCSI";
