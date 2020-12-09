# COMP3311 20T3 Ass3 ... Python helper functions
# add here any functions to share between Python scripts 
def repint(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

def normal(s):
    return s.capitalize().replace("_", " ")


