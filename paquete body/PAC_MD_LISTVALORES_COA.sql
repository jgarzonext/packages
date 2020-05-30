--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTVALORES_COA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTVALORES_COA" AS
/******************************************************************************
 NOMBRE: PAC_MD_LISTVALORES_COA
 PROPÓSITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripción
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 2.0       23/05/2012 AVT             2. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
 3.0       02/10/2012 AVT             3. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
 4.0       07/11/2012 AVT             4. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
 5.0       05/03/2013 JDS             4. 0025098: Qtracker: 5616 i 5617 Inconsistencias al generar cuenta corriente del coaseguro
 6.0       18/04/2013 ECP             6. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran. Nota 142806
 7.0       14/06/2013 KBR             7. 0027322: LCOL_A004-LErrors QT de pantalles de REA/COA (Incidencia en lista de valores Tipo Coaseguro)
 8.0       20/02/2014 AGG             8. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
 9.0		02/03/2018	JAAB			9. QT-1620 CONF f_get_tipo_importe visualizar solo los conceptos necesarios.
******************************************************************************/

   /*************************************************************************
      Recupera la lista desplegable de conceptos de la cuenta técnica del Caoseguro
      param out mensajes : mensajes de error (CMOVIMI de CTACOASEGURO)
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipo_movcta(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_COA.f_get_tipo_movcta ';
      terror         VARCHAR2(200)
                                 := 'Error recuperar tipos de movimientos de cuenta Coaseguro';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(152, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_movcta;

   /*************************************************************************
      Recupera la lista de valores del desplegable Tipo de Coaseguro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   --Ini bug 23183 -- ECP -- 18/04/2013
   FUNCTION f_get_tipcoaseguro(
      pcempres IN NUMBER,
      pcvalor IN NUMBER,
      pcatribu IN NUMBER,
      pcvalordep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      --Fin bug 23183 -- ECP -- 18/04/2013
   RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_COA.F_Get_TipCoaseguro';
      terror         VARCHAR2(200) := 'Error recuperar tipos de coaseguro';
      --Ini bug 23183 -- ECP -- 18/04/2013
      vdatos         NUMBER := 0;
      vcatribu       detvalores.catribu%TYPE;
      vtatribu       detvalores.tatribu%TYPE;
   --Fin bug 23183 -- ECP -- 18/04/2013
   BEGIN
      --Ini bug 23183 -- ECP -- 18/04/2013
      --KBR Uso de NVL en parametro PCVALOR --14/06/2013 --27322
      cur := pac_md_listvalores.f_detvalores_dep(pcempres, NVL(pcvalor, 0), pcatribu,
                                                 pcvalordep, mensajes);

      FETCH cur
       INTO vcatribu, vtatribu;

      IF cur%FOUND THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         cur := pac_md_listvalores.f_detvalores_dep(pcempres, pcvalor, pcatribu, pcvalordep,
                                                    mensajes);
         vdatos := 1;
      END IF;

      IF vdatos = 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         cur := pac_md_listvalores.f_detvalores(pcvalordep, mensajes);   -- Ind. tipo coaseguro
      END IF;

      -- 23830 AVT 07/11/2012 es canvia el valor 59 pel 800109
      --Fin bug 23183 -- ECP -- 18/04/2013
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipcoaseguro;

   /*************************************************************************
      Recupera la lista desplegable de tipos importes de la cuenta técnica del
      Caoseguro
      param out mensajes : mensajes de error (CIMPORT de CTACOASEGURO)
      return             : ref cursor
      Nova funcio: 22076 AVT 02/01/2012
   *************************************************************************/
   FUNCTION f_get_tipo_importe(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_COA.f_get_tipo_importe ';
      terror         VARCHAR2(200) := 'Error recuperar tipos de importes de cuenta Coaseguro';
   BEGIN
      --AGG 20/02/2014
      --BUG 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
      --Solo se utilizará el listvalores 1125 en el caso de Liberty
      IF pcempres = 12 THEN
         cur := pac_md_listvalores.f_detvalores(1125, mensajes);
      ELSIF pcempres = 24 THEN --JAAB CONF QT-1620
         cur := pac_md_listvalores.f_detvalorescond(150, ' CATRIBU IN (1, 2, 4, 13, 39, 38, 42, 5, 17, 32, 33, 43, 44, 45, 46, 47)', mensajes);
      ELSE
         cur := pac_md_listvalores.f_detvalores(150, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_importe;
END pac_md_listvalores_coa;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_COA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_COA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_COA" TO "PROGRAMADORESCSI";
