/* Formatted on 2019/08/28 10:52 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY "PAC_RANGO_DIAN"
AS
   /******************************************************************************
     NOMBRE:      PAC_RANGO_DIAN
     PROPÓSITO:   Package de rango dian

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        --/--/----   ---                1. Creación del package.Recupera Versiones Dian
       2.0        08/05/2019   JLTS               2. IAXIS-3925 Ajuste del proceso para activar rangos inactivos si cumplen
                                                     con las condiciones
     3.0        19/06/2019   JLTS               3. Se incluye esta columna SPRODUC en f_set_versionesdian
     4.0        28/08/2019   ECP                4. IAXIS-3592. Proceso de terminaci�n por no pago
   *************************************************************************/
   FUNCTION f_get_versionesdian (
      psrdian       IN       NUMBER,
      presolucion   IN       NUMBER,
      psucursal     IN       NUMBER,
      pcgrupo       IN       VARCHAR2,
      pdescrip      IN       VARCHAR2,
      pusuario      IN       VARCHAR2,
      pmail         IN       NUMBER,
      pcactivi      IN       NUMBER,
      pcramo        IN       NUMBER,
      ptestado      IN       NUMBER,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      vpasexec      NUMBER;
      vnumerr       NUMBER;
      vparam        VARCHAR2 (1000);
      vobjectname   VARCHAR2 (200)  := 'PAC_RANGO_DIAN.f_get_versionesdian';
      vsquery       VARCHAR2 (5000);
      cur           sys_refcursor;
   BEGIN
      vpasexec := 5;
      vsquery :=
         'SELECT r.SRDIAN,
                    r.NRESOL,
                    r.CAGENTE,
                    pac_isqlfor.f_agente(r.CAGENTE) TSUCURSAL,
                    r.CGRUPO,
                    (select t.TGRUPO from  CODGRUPODIAN t
                      where t.CGRUPO   = r.CGRUPO) TGRUPO,
                    r.FRESOL,
                    r.FINIVIG,
                    r.FFINVIG,
                    r.TDESCRIP,
                    r.NINICIAL,
                    r.NFINAL,
                    r.CUSU,
                    r.NUSU,
										pac_user.f_nomuser(r.NUSU) tnusu,
                    r.TESTADO,
                    ff_desvalorfijo(862,pac_md_common.f_get_cxtidioma,r.TESTADO) TTESTADO,
                    r.CENVCORR,
                    ff_desvalorfijo(108,pac_md_common.f_get_cxtidioma,r.CENVCORR) TCENVCORR,
                    r.NAVISO,
                    r.NCERTAVI,
										r.sproduc,
										r.cramo,
										pac_isqlfor.f_ramo(r.cramo,pac_md_common.f_get_cxtidioma) tramo,
                    r.NCONTADOR,
                    r.FALTA,
										r.cactivi
                  FROM RANGO_DIAN r';
      vpasexec := 10;
      vsquery := vsquery || ' WHERE 1 = 1 ';

      IF psrdian IS NOT NULL
      THEN
         -- Se utiliza para la consulta en la pantalla cuando se va a modificar el registro exacto
         vpasexec := 20;
         vsquery :=
             vsquery || ' AND srdian = ' || NVL (TO_CHAR (psrdian), 'SRDIAN');
      END IF;

      IF presolucion IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' AND NRESOL = '
            || NVL (TO_CHAR (presolucion), 'NRESOL');
         vpasexec := 15;
      END IF;

      IF psucursal IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' AND CAGENTE = '
            || NVL (TO_CHAR (psucursal), 'CAGENTE');
         vpasexec := 25;
      END IF;

      IF pcgrupo IS NOT NULL
      THEN
         vsquery := vsquery || ' AND CGRUPO = ''' || pcgrupo || '''';
      END IF;

      vpasexec := 30;

      IF pcactivi IS NOT NULL
      THEN
         vsquery := vsquery || ' AND CACTIVI = ''' || pcactivi || '''';
      END IF;

      vpasexec := 35;

      IF pdescrip IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' AND UPPER(TDESCRIP) LIKE ''%'
            || UPPER (pdescrip)
            || '%''';
      END IF;

      vpasexec := 40;

      IF pusuario IS NOT NULL
      THEN
         vsquery := vsquery || ' AND NUSU = ''' || pusuario || '''';
      END IF;

      vpasexec := 45;

      IF pmail IS NOT NULL
      THEN
         vsquery := vsquery || ' AND CENVCORR = ''' || pmail || '''';
      END IF;

      IF ptestado IS NOT NULL
      THEN
         vsquery := vsquery || ' AND TESTADO = ''' || ptestado || '''';
      END IF;

      IF pcramo IS NOT NULL
      THEN
         vsquery := vsquery || ' AND CRAMO = ''' || pcramo || '''';
      END IF;

      vpasexec := 50;
      vnumerr := pac_log.f_log_consultas (vsquery, vobjectname, 1);
      cur := pac_md_listvalores.f_opencursor (vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_versionesdian;

   FUNCTION f_set_versionesdian (
      psrdian      IN       NUMBER,
      pnresol      IN       NUMBER,
      pcagente     IN       NUMBER,
      pcgrupo      IN       VARCHAR2,
      pfresol      IN       DATE,
      pfinivig     IN       DATE,
      pffinvig     IN       DATE,
      ptdescrip    IN       VARCHAR2,
      pninicial    IN       NUMBER,
      pnfinal      IN       NUMBER,
      pcusu        IN       VARCHAR2,
      ptestado     IN       VARCHAR2,
      pcenvcorr    IN       VARCHAR2,
      pnaviso      IN       NUMBER,
      pncertavi    IN       NUMBER,
      pncontador   IN       NUMBER,
      pmodo        IN       VARCHAR2,
      pcactivi     IN       NUMBER,
      pcramo       IN       NUMBER,
      psproduc     IN       NUMBER,
                       --IAXIS-3288 -JLTS -19/06/2019. Se incluye esta columna
      mensajes     OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec             NUMBER;
      vnumerr              NUMBER;
      vparam               VARCHAR2 (5000)
         :=    'psrdian = '
            || psrdian
            || ' pnresol   ='
            || pnresol
            || ' pcagente  ='
            || pcagente
            || ' pcgrupo   ='
            || pcgrupo
            || ' pfresol   ='
            || pfresol
            || ' pfinivig  ='
            || pfinivig
            || ' pffinvig  ='
            || pffinvig
            || ' ptdescrip ='
            || ptdescrip
            || ' pninicial ='
            || pninicial
            || ' pnfinal   ='
            || pnfinal
            || ' pcusu     ='
            || pcusu
            || ' ptestado  ='
            || ptestado
            || ' pcenvcorr ='
            || pcenvcorr
            || ' pnaviso   ='
            || pnaviso
            || ' pncertavi ='
            || pncertavi
            || ' pncontador='
            || pncontador
            || ' PMODO     ='
            || pmodo
            || ' PCACTIVI  ='
            || pcactivi
            || ' pcramo    ='
            || pcramo;
      vobjectname          VARCHAR2 (200)
                                       := 'PAC_RANGO_DIAN.f_set_versionesdian';
      v_existe_srdian      NUMBER          := 0;
      v_secuencia_srdian   NUMBER          := 0;
      v_mail_usu           VARCHAR2 (100);
      v_existe_cgrupo      VARCHAR2 (100);
      --INI
      v_ncontador          NUMBER          := 0;

      FUNCTION f_contador (psrdian1 IN NUMBER)
         RETURN NUMBER
      IS
         v_ncontador1   NUMBER := 0;
      BEGIN
         SELECT MAX (r.ncontador)
           INTO v_ncontador1
           FROM rango_dian r
          WHERE EXISTS (
                   SELECT 1
                     FROM rango_dian r1
                    WHERE r1.srdian = psrdian1
                      AND r1.cagente = r.cagente
                      AND r1.cgrupo = r.cgrupo);

         RETURN v_ncontador1;
      END f_contador;
   -- FIN
   BEGIN
      BEGIN
         SELECT srdian
           INTO v_existe_srdian
           FROM rango_dian r
          WHERE cagente = pcagente
            AND fresol = pfresol
            AND cgrupo = pcgrupo
            AND nresol =
                   pnresol
-- OR (pfinivig BETWEEN finivig AND ffinvig OR pffinvig BETWEEN finivig AND ffinvig))
            AND r.testado = ptestado;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_existe_srdian := 0;
      END;

      IF (v_existe_srdian = 0 AND pmodo = 'ALTA')
      THEN
         v_secuencia_srdian := srango_dian.NEXTVAL;

         INSERT INTO rango_dian
                     (srdian, nresol, cagente, fresol,
                      finivig, ffinvig, falta, fmod, tdescrip,
                      ninicial, nfinal, cusu, musu, nusu, testado,
                      cenvcorr, naviso, ncertavi, ncontador, cgrupo,
                      cactivi, cramo, sproduc
                     )
              VALUES (v_secuencia_srdian, pnresol, pcagente, pfresol,
                      pfinivig, pffinvig, f_sysdate, '', ptdescrip,
                      pninicial, pnfinal, f_user, '', pcusu, ptestado,
                      pcenvcorr, pnaviso, pncertavi, pninicial - 1, pcgrupo,
                      pcactivi, pcramo, psproduc
                     );

         -- Se toma el maximo
         v_ncontador := f_contador (v_secuencia_srdian);

         UPDATE rango_dian r
            SET /*(r.sproduc, r.cramo) =
                 (SELECT a.sproduc, a.cramo FROM activiprod a WHERE r.cgrupo = a.cgrupo)
                     ,*/ r.ncontador = v_ncontador
          WHERE r.srdian = v_secuencia_srdian;
      END IF;

      IF pcusu IS NOT NULL AND pcenvcorr = 1
      THEN
         SELECT u.mail_usu
           INTO v_mail_usu
           FROM usuarios u
          WHERE u.cusuari = pcusu;
      END IF;

      IF v_mail_usu IS NOT NULL
      THEN
         BEGIN
            INSERT INTO destinatarios_correo
                        (scorreo, destinatario, descripcion, direccion
                        )
                 VALUES (305, 'CONTACTO', 'CONTACTO', v_mail_usu
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF (pmodo = 'MODIFICACION')
      THEN
         BEGIN
            UPDATE rango_dian r
               SET ffinvig = pffinvig,
                   r.nfinal = pnfinal,
                   tdescrip = ptdescrip,
                   testado = ptestado,
                   cenvcorr = pcenvcorr,
                   ncertavi = pncertavi,
                   naviso = pnaviso,
                   nusu = pcusu,
                   musu = f_user,
                   fmod = f_sysdate
             WHERE srdian = psrdian;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 1;
         END;
      ELSIF (v_existe_srdian > 0 AND pmodo = 'ALTA')
      THEN
         RETURN 1;                                  /*El registro ya existe*/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobjectname,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            NULL,
                                            SQLCODE,
                                            SQLERRM
                                           );
         RETURN 1;
   END f_set_versionesdian;

   FUNCTION f_get_gruposdian
      RETURN VARCHAR2
   IS
      vpasexec      NUMBER;
      vnumerr       NUMBER;
      vparam        VARCHAR2 (1000);
      vobjectname   VARCHAR2 (200)  := 'PAC_RANGO_DIAN.f_get_gruposdian';
      vsquery       VARCHAR2 (5000);
      cur           sys_refcursor;
   BEGIN
      vpasexec := 1;
      vsquery := 'SELECT r.CGRUPO, r.TGRUPO ' || '  FROM CODGRUPODIAN r';
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      SQLERRM
                     );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_gruposdian;

   /*FUNCTION f_generar_certificado(psseguro IN NUMBER,
                                  pnmovimi IN NUMBER,
                                  pcagente IN NUMBER,
                                  pcgrupo  IN VARCHAR2,
                                  pcactivi IN NUMBER) RETURN NUMBER IS
     vpasexec    NUMBER;
     vnumerr     NUMBER;
     vparam      VARCHAR2(1000) := '-psseguro:' || psseguro || ' -pnmovimi:' || pnmovimi || ' -pcagente:' || pcagente ||
                                   ' -pcgrupo:' || pcgrupo;
     vobjectname VARCHAR2(200) := 'PAC_RANGO_DIAN.f_generar_certificado';
     vncontador  NUMBER;
     vsucursal   NUMBER;
   BEGIN
     vsucursal := pac_agentes.f_get_cageliq(pac_md_common.f_get_cxtempresa(), 2, pcagente);
     BEGIN
       SELECT nvl(ncontador, ninicial) + 1
         INTO vncontador
         FROM rango_dian
        WHERE cgrupo = pcgrupo
          AND cagente = vsucursal
          AND cactivi = pcactivi
          AND F_SYSDATE BETWEEN finivig AND ffinvig;
     EXCEPTION
       WHEN no_data_found THEN
         vncontador := NULL;

       WHEN OTHERS THEN
         SELECT MAX(nvl(ncontador, ninicial) + 1)
           INTO vncontador
           FROM rango_dian
          WHERE cgrupo = pcgrupo
            AND cagente = vsucursal
            AND cactivi = pcactivi
            AND F_SYSDATE BETWEEN finivig AND ffinvig;
     END;
     vpasexec := 1;
     INSERT INTO rango_dian_movseguro
       (sseguro, nmovimi, ncertdian, falta, cusualta)
     VALUES
         --(psseguro, pnmovimi, pcgrupo || vsucursal || vncontador, f_sysdate, f_user);-- se pidio omitir el número de sucursal del certificado DIAN
       (psseguro, pnmovimi, pcgrupo || vncontador, f_sysdate, f_user);

     UPDATE rango_dian
        SET ncontador = vncontador
      WHERE cgrupo = pcgrupo
        AND cagente = vsucursal;

     RETURN 0;
   EXCEPTION
     WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);

       RETURN 1;
   END f_generar_certificado;*/-- INI BUG 3324 - SGM Interacción el Rango DIAN con la póliza (No. Certificado)
   FUNCTION f_asigna_rangodian (psseguro IN NUMBER, pmovimi IN NUMBER)
      RETURN NUMBER
   IS
      vconsecutivo   rango_dian.ncontador%TYPE;
      vcertdian      VARCHAR2 (20);
      vproduc        seguros.sproduc%TYPE;
      ramo           NUMBER (8);
      modalidad      NUMBER (2);
      tipseg         NUMBER (2);
      colect         NUMBER (2);
      situac         NUMBER (2);
      vsproduc       NUMBER (6)                  := 0;
      vcagente       NUMBER;
      vcgrupo        VARCHAR2 (10);
      vnumerr        NUMBER;
      vcactivi       NUMBER;
      vpasexec       NUMBER;
      vsucursal      NUMBER;
      vncontador     NUMBER;
      -- INI -IAXIS-3925 - JLTS - 08/05/2019
      v_srdian       rango_dian.srdian%TYPE      := 0;
      v_estado       rango_dian.testado%TYPE     := NULL;
   -- FIN -IAXIS-3925 - JLTS - 08/05/2019
   BEGIN
      -- INi IAXIS-3592 -- ECP -- 28/08/2019
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, csituac, sproduc, cagente,
                cactivi, pac_agentes.f_get_cageliq (cempres, 2, cagente)
           INTO ramo, modalidad, tipseg, colect, situac, vsproduc, vcagente,
                vcactivi, vsucursal
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 101919
                     );
            RETURN 101919;        --(Error al leer datos de la tabla SEGUROS)
      END;
 -- Fin IAXIS-3592 -- ECP -- 28/08/2019
      BEGIN
         SELECT cgrupo
           INTO vcgrupo
           FROM activiprod a
          WHERE a.sproduc = vsproduc AND a.cactivi = vcactivi;
      EXCEPTION
         WHEN OTHERS
         THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 89906259
                     );
            RETURN 89906259;         --(producto y actividad no configurados)
      END;

      -- Se seleciona el maximo contador mas uno
      BEGIN
         SELECT     NVL (r.ncontador, 1) + 1
               INTO vncontador
               FROM rango_dian r
              WHERE r.cagente = vsucursal
                AND r.cgrupo = vcgrupo
                AND r.testado IN (1, 2)
                AND ROWNUM = 1
         FOR UPDATE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian-->',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 89906252
                     );
            RETURN 89906252;
                         --No existe resolución para ese producto y/o agente
      END;

      -- Se busca la resolución a tener en cuenta
      BEGIN
         SELECT abc.srdian, abc.testado
           INTO v_srdian, v_estado
           FROM (SELECT   r.*
                     FROM rango_dian r
                    WHERE r.cagente = vsucursal
                      AND r.cgrupo = vcgrupo
                      AND r.testado IN (1, 2)
                      AND TRUNC (SYSDATE) - TRUNC (r.finivig) >= 0
                      AND r.ninicial <= vncontador
                      AND vncontador <= r.nfinal
                 ORDER BY TRUNC (SYSDATE) - TRUNC (r.finivig)) abc
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
         -- INi IAXIS-3592 -- ECP -- 28/08/2019
            p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 89906252
                     );
                     -- Fin IAXIS-3592 -- ECP -- 28/08/2019
            RETURN 89906252;
                         --No existe resolución para ese producto y/o agente
      END;

      IF v_estado = 2
      THEN
         -- Se procede a hacer el switch de activo -> inactivo (v_srdian_inact)
         UPDATE rango_dian r
            SET r.testado = 1
          WHERE r.srdian = v_srdian;

         -- Se procede a hacer el switch de inactivo -> activo (v_srdian_act)
         UPDATE rango_dian r
            SET r.testado = 2
          WHERE r.srdian != v_srdian
            AND r.cagente = vsucursal
            AND r.cgrupo = vcgrupo
            AND r.testado IN (1, 2);
      END IF;

      BEGIN
         INSERT INTO rango_dian_movseguro
                     (sseguro, nmovimi, ncertdian, falta,
                      cusualta
                     )
              VALUES 
                     --(psseguro, pmovimi, vcgrupo||vsucursal||vncontador, f_sysdate, f_user); -- se pidio omitir el número de sucursal del certificado DIAN
         (            psseguro, pmovimi, vcgrupo || vncontador, f_sysdate,
                      f_user
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 2000093
                     );
            RETURN 2000093;
                         --Error al insertar en la tabla RANGO_DIAN_MOVSEGURO
      END;

      UPDATE rango_dian r
         SET ncontador = vncontador,
             ncertavi = nfinal - vncontador
       WHERE r.cagente = vsucursal
         AND r.cgrupo = vcgrupo
         AND r.testado IN (1, 2);

      -- Si todo ha ido bien
      RETURN 0;
   -- INI -IAXIS-3925 - JLTS - 08/05/2019
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'f_asigna_rangodian',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' psseguro-->'
                      || psseguro
                      || ' vsucursal-->'
                      || vsucursal
                      || ' vcgrupo-->'
                      || vcgrupo
                      || ' vcagente-->'
                      || vcagente
                      || ' vncontador-->'
                      || vncontador
                      || ' vncontador-->'
                      || vncontador
                      || ' Error-->'
                      || 2000091
                     );
         RETURN 2000091;                 -- Error en el proceso de Rango Dian
   -- FIN -IAXIS-3925 - JLTS - 08/05/2019
   END f_asigna_rangodian;
-- FIN BUG 3324 - SGM Interacción el Rango DIAN con la p????a (No. Certificado)
END pac_rango_dian;
/