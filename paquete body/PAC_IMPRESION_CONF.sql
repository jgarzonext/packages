--------------------------------------------------------
--  DDL for Package Body PAC_IMPRESION_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_IMPRESION_CONF" AS
   /****************************************************************************
     NOMBRE:    pac_impresion_conf
     PROPSITO: Funciones para validar si un documento se debe generar o no

     REVISIONES:
     Ver        Fecha       Autor            Descripcin
     ---------  ----------  ---------------  --------------------------------------
     1.0        10/10/2016  JTS
	 2.0        25/04/2019  ACL              IAXIS-3095 Se crean las funciones f_clausulado y f_val_consorcio
	 3.0        07/05/2019  ACL              IAXIS-3095 Se ajusta la función f_mov_recibo
	 4.0        10/05/2019  ACL              IAXIS-3095 Se ajustan las funciones de clausulados.
   ****************************************************************************/

   /*************************************************************************
      FUNCTION f_mov_recibo
      El movimiento tiene recibo?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
      FUNCTION f_mov_recibo(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER is
      vcount number;
	  -- Ini IAXIS-3095 - ACL - 07/05/2019
      v_prima number;
   begin
      select decode(count(1),0,0,1)
        into vcount
        from seguros
       where sseguro = p_sseguro
         and cactivi in (0, 2)  
         and cramo in (801, 806, 805);
  
    IF vcount > 0 THEN
        select vd.iprinet+vd.irecfra+vd.icednet
        into v_prima
        from recibos r, vdetrecibos vd
        where r.sseguro = p_sseguro
        and r.nmovimi = p_nmovimi
        and r.nrecibo = vd.nrecibo;  
    ELSE 
      RETURN 0;
    END IF;
    
    IF v_prima > 0 THEN 
      RETURN 1;
    ELSE 
      RETURN 0;
    END IF;

   exception
      when others then
        return 0;
   end f_mov_recibo;
	-- Fin IAXIS-3095 - ACL - 07/05/2019
   /*************************************************************************
      FUNCTION f_coacedido
      El seguro tiene coaseeguro cedido?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
   FUNCTION f_coacedido(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER is
      vcount number;
   begin
      select decode(count(1),0,0,1)
        into vcount
        from coacedido
       where sseguro = p_sseguro;

      return vcount;
   exception
      when others then
        return 0;
   end f_coacedido;

  /*************************************************************************
      FUNCTION f_consorcio
      El tomador es un consorcio?
      param in p_sproduc    : Cdigo del producto
      param in p_ctipo      : Tipo de impresion
      param in p_ccodplan   : Cdigo de plantilla
      param in p_fdesde     : Fecha de vigencia
      param in p_sseguro    : Cdigo de seguro
      return             : 1 se genera, 0 no se genera
   *************************************************************************/
   FUNCTION f_consorcio(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER is
      vcount number;
   begin
      select decode(count(1),0,0,1)
        into vcount
        from tomadores t, per_parpersonas p
       where t.sseguro = p_sseguro
         and t.sperson = p.sperson
         and p.cparam = 'PER_ASO_JURIDICA'
         and p.nvalpar is not null;

      return vcount;
   exception
      when others then
        return 0;
   end f_consorcio;

      /*************************************************************************
        FUNCTION f_garantias
        Garantias genrico
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_garantias(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_gar         NUMBER;
   BEGIN
      SELECT substr(p_ccodplan,instr(p_ccodplan,'_G')+2)
        INTO v_gar
        FROM DUAL;

      --Tiene la Garantia?
      SELECT COUNT(1)
        INTO v_ret
        FROM garanseg
       WHERE sseguro = p_sseguro
         AND cgarant = v_gar
         AND ffinefe IS NULL;

      IF v_ret > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_garantias', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_garantias;

      /*************************************************************************
        FUNCTION f_gar_respcivil
        Garantias de RESPONSABILIDAD CIVIL CRUZADA
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_gar_respcivil(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_gar         NUMBER;
   BEGIN
      --Tiene la garantia RESPONSABILIDAD CIVIL CRUZADA
      SELECT COUNT(1)
        INTO v_ret
        FROM garanseg
       WHERE sseguro = p_sseguro
         AND cgarant in (7035,7055,7697)
         AND ffinefe IS NULL;

      IF v_ret > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_gar_respcivil', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_gar_respcivil;

      /*************************************************************************
        FUNCTION f_regprivcontratacion
        Regimen privado de contratacin
        param in p_sproduc    : Cdigo del producto
        param in p_ctipo      : Tipo de impresion
        param in p_ccodplan   : Cdigo de plantilla
        param in p_fdesde     : Fecha de vigencia
        param in p_sseguro    : Cdigo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_regprivcontratacion(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_gar         NUMBER;
   BEGIN
      --Tiene la pregunta Regimen privado de contratacin
      select count(1)
        INTO v_ret
        from pregunpolseg
        where sseguro = p_sseguro
        and cpregun = 2876
        and crespue = 4
        and nmovimi = (select max(nmovimi)
                        from pregunpolseg
                        where sseguro = p_sseguro
                        and cpregun = 2876
                        and nmovimi <= nvl(p_nmovimi,nmovimi));

      IF v_ret > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_regprivcontratacion', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_regprivcontratacion;
    
   
   /*************************************************************************
        FUNCTION f_clausula_ecopetrol
        Regimen privado de contratacin
        param in psseguros    : Cdigo del producto
      
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
  FUNCTION f_clausula_ecopetrol(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_cactivi         NUMBER := 0;
      valor             NUMBER := 0;
      V_crespue         NUMBER := 0;
      valor1            NUMBER := 0;
      
   BEGIN
   begin
    SELECT cactivi
        INTO v_cactivi
        from seguros
        where sseguro = p_sseguro;
        exception when no_data_found then 
           v_cactivi:=0;
          end;
        IF v_cactivi = 2 THEN
        RETURN 1;	
			ELSE
			RETURN 0;
        END IF;
      
      
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausula_ecopetrol', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausula_ecopetrol;
   
 /*************************************************************************
      FUNCTION f_clausula_ecopetrol_gb
      Regimen privado de contratacin
      param in psseguros    : Cdigo del producto

      return             : 1 se imprime, 0 no se imprime
   *************************************************************************/
   FUNCTION f_clausula_ecopetrol_gb (
      p_sproduc    IN   NUMBER,
      p_ctipo      IN   NUMBER,
      p_ccodplan   IN   VARCHAR2,
      p_fdesde     IN   DATE,
      p_sseguro    IN   NUMBER,
      p_nmovimi    IN   NUMBER DEFAULT NULL,
      p_nrecibo    IN   NUMBER DEFAULT NULL,
      p_nsinies    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_cactivi   NUMBER := 0;
      valor       NUMBER := 0;
      v_crespue   NUMBER := 0;
      valor1      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT crespue
           INTO v_crespue
           FROM estpregunpolseg
          WHERE sseguro = p_sseguro AND cpregun = 2913;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_crespue := 0;
      END;
	  
	  if v_crespue = 0 then
	   BEGIN
         SELECT crespue
           INTO v_crespue
           FROM pregunpolseg
          WHERE sseguro = p_sseguro AND cpregun = 2913;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_crespue := 0;
      END;
	  end if;

      IF v_crespue = 3
      THEN
         RETURN 1;
      else
         return 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPRESION_CONF.f_clausula_ecopetrol_gb',
                      1,
                      'OTHERS',
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 0;
   END f_clausula_ecopetrol_gb;   
   
      
        /*************************************************************************
        FUNCTION f_clausulado
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_val_consorcio(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sperson      NUMBER;
      v_ctipide      NUMBER;
      v_ctipsoci     NUMBER;
   BEGIN
     select t.sperson 
        into v_sperson
        from tomadores t
       where t.sseguro = p_sseguro;

    IF  v_sperson IS NOT NULL THEN
        select p.ctipide 
        into v_ctipide 
        from per_personas p
        where p.sperson = v_sperson;
    END IF;

    IF v_ctipide = 0 THEN
        RETURN 1;
    ELSE
      select fg.ctipsoci
      into v_ctipsoci
      from fin_general fg
      where fg.sperson = v_sperson;

      IF v_ctipsoci IN (9, 10) THEN
         RETURN 1;
      ELSE 
        RETURN 0;
      END IF;
    END IF;
	
     EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_val_consorcio', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
    END f_val_consorcio;
	
     /*************************************************************************
        FUNCTION f_clausulado_ecop
        Clausulado producto Derivado de Contrato actividad Ecopetrol
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_ecop(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 2 THEN
          select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 22
           and nmovimi = 1;     
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_ecop', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_ecop;
   
   
    /*************************************************************************
        FUNCTION f_clausulado_part_zf
        Clausulado producto Derivado de Contrato actividad Particular Zona Franca
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_zf(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 1 THEN
         select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 21
           and nmovimi = 1; 
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_part_zf', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_part_zf;
   
    /*************************************************************************
        FUNCTION f_clausulado_part_p
        Clausulado producto Derivado de Contrato actividad Particular '.'
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_p(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 1 THEN
         select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 19
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_part_p', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_part_p;
   
    /*************************************************************************
        FUNCTION f_clausulado_part_brep
        Clausulado producto Derivado de Contrato actividad Particular Banco de la Rep�blica
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_part_brep(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 1 THEN
         select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 20
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_part_brep', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_part_brep;
   
    /*************************************************************************
        FUNCTION f_clausulado_gu_dec1082
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_dec1082(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
   
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 0 THEN
           select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 5
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_gu_dec1082', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_gu_dec1082;

    /*************************************************************************
        FUNCTION f_clausulado_gu_rpc
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_rpc(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
   
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 0 THEN
           select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 4
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_gu_rpc', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_gu_rpc;

    /*************************************************************************
        FUNCTION f_clausulado_gu_ani
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_gu_ani(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
   
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 0 THEN
           select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 24
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_gu_ani', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_gu_ani;

     /*************************************************************************
        FUNCTION f_clausulado_sp
        Clausulado producto Derivado de Contrato
        param in p_sseguro    : C�digo de seguro
        return             : 1 se imprime, 0 no se imprime
     *************************************************************************/
   FUNCTION f_clausulado_sp(
      p_sproduc IN NUMBER,
      p_ctipo IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_fdesde IN DATE,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL,
      p_nsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_ret          NUMBER := 0;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      
   BEGIN
      select s.sproduc, s.cactivi
      into v_sproduc, v_cactivi
       from seguros s
       where s.sseguro = p_sseguro;
       
     IF v_sproduc in (80001, 80002, 80003, 80004, 80005, 80006) THEN
        IF v_cactivi = 3 THEN
           select count(1)
           INTO v_ret
           from pregunpolseg
           where sseguro = p_sseguro
           and cpregun = 2876
           and crespue = 23
           and nmovimi = 1;
      END IF;
    END IF;
	
	IF v_ret > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
	
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_IMPRESION_CONF.f_clausulado_sp', 1, 'OTHERS',
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_clausulado_sp;	
end pac_impresion_conf;

/
