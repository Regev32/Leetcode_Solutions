def excavate_atom(formula):
    atom = formula.pop(0)
    while formula and formula[0].islower():
        atom += formula.pop(0)
    return atom, formula

def excavate_mult(formula):
    mult = ''
    while formula and formula[0].isdigit():
        mult += formula.pop(0)
    if not mult:
        mult = '1'
    return int(mult), formula

def excavate_bracket(formula):
    atoms = {}
    formula.pop(0) # formula[0] = '('
    while formula and formula[0] != ')':
        if formula[0].isupper():
            atom, formula = excavate_atom(formula)
            mult, formula = excavate_mult(formula)
            atoms[atom] = atoms.get(atom, 0) + mult
        elif formula[0] == '(':
            d, m, formula = excavate_bracket(formula)
            for key, value in d.items():
                atoms[key] = atoms.get(key, 0) + value
    formula.pop(0)
    mult, formula = excavate_mult(formula)
    for key, value in atoms.items():
        atoms[key] *= mult
    return atoms, mult, formula

class Solution(object):
    def countOfAtoms(self, formula):
        """
        :type formula: str
        :rtype: str
        """
        atoms = {}
        formula = list(formula)
        while formula:
            if formula[0].isupper(): # atom -> excavate atom and his multiplicity
                atom, formula = excavate_atom(formula)
                mult, formula = excavate_mult(formula)
                atoms[atom] = atoms.get(atom, 0) + mult
            elif formula[0] == '(': # brackets -> excavate all atoms there and total multiplicity
                d, m, formula = excavate_bracket(formula)
                for key, value in d.items():
                    atoms[key] = atoms.get(key, 0) + value
        formula = ''
        for atom, count in sorted(atoms.items()):
            formula += atom + (str(count) if count > 1 else '')
        return formula