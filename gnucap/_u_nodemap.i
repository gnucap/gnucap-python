/* Copyright (C) 2018 Felix Salfelder
 * Author: Felix Salfelder <felix@salfelder.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 *------------------------------------------------------------------
 */
%module(directors="0", allprotected="1") u_nodemap

%{
#include <u_nodemap.h>
#include <e_node.h>
%}

%include "std_string.i"
%include "_e_node.i"

class NODE_MAP {
private:
  std::map<const std::string, NODE*> _node_map;
  explicit  NODE_MAP(const NODE_MAP&);

public:
  explicit  NODE_MAP();
	   ~NODE_MAP();
  //NODE*     operator[](std::string);
  //NODE*     new_node(std::string);

//  typedef std::map<const std::string, NODE*>::iterator iterator;
//  typedef std::map<const std::string, NODE*>::const_iterator const_iterator;
//
//  const_iterator begin()const		{return _node_map.begin();}
//  const_iterator end()const		{return _node_map.end();}
  int		 how_many()const	{return static_cast<int>(_node_map.size()-1);}
};

%extend NODE_MAP {
  unsigned name2matrixnumber_hack(std::string const& n){
    if((*self)[n]){
      return (*self)[n]->matrix_number();
    }else{
      return -1u;
    }
  }

  inline NODE const& __getitem__(std::string /*const?*/ s){
    return *(*self)[s];
  }
}
