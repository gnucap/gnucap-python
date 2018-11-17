#ifndef GC_SWIG_WRAP_H
#define GC_SWIG_WRAP_H
#include <md.h>
//TODO: untangle
struct COMPLEX_array_t {
  operator COMPLEX*() { return _t; }
  COMPLEX& get(unsigned i){return _t[i];}
  COMPLEX& set(unsigned i, COMPLEX const& a){return _t[i]=a;}
  COMPLEX* _t;
};
inline COMPLEX& get_z(COMPLEX* n, unsigned x){
return n[x];
}


#include <c_comand.h>
#include <l_dispatcher.h>
#include <s__.h>
#include <memory>

#if 0
class sim : public SIM {
protected:
  explicit sim() : SIM() { untested(); }
  ~sim() { untested(); }
public:
  virtual void  setup(CS&)=0;
  virtual void  sweep()=0;
  virtual void  do_it(CS&, CARD_LIST*){ incomplete(); };
};
#endif

#include <e_compon.h>

#if 0
class component : public COMPONENT {
protected:
  explicit component(const COMPONENT& c) : COMPONENT(c) { untested(); }
  explicit component() : COMPONENT() { untested(); }

public: // these pure in COMPONENT
  virtual CARD*	 clone()const{ unreachable(); }
  virtual std::string port_name(int)const { unreachable(); }
  virtual std::string value_name()const { unreachable(); }

public:	// obsolete -- do not use in new code
  bool print_type_in_spice()const { untested(); return false; }
  bool use_obsolete_callback_parse()const { untested(); return false; }
  bool use_obsolete_callback_print()const { untested(); return false; }
  void print_args_obsolete_callback(OMSTREAM&, LANGUAGE*)const { unreachable(); }
  void obsolete_move_parameters_from_common(const COMMON_COMPONENT*) { unreachable(); }
};
#endif

class card : public CARD {
public:
  explicit card() : CARD()  {}
public: // pure?
  virtual CARD* clone(CS&){ unreachable(); return nullptr;}
};

std::string command(char const*command);
void parse(char const*command);

inline void test_dummy(CARD *c){ untested(); }

class BSCR{
public:
  BSCR( BSMATRIX<COMPLEX> const& m, size_t r) : _m(m), _r(r){ }
  COMPLEX get(size_t x) const{
	  return _m.s(_r, x);
  }

private:
  BSMATRIX<COMPLEX> const& _m;
  size_t _r;
};

#endif
