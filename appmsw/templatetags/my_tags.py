from django import template
register = template.Library()

# <p>Instance: {% iris_piece iris_portal.instance delimiter="*" num=1 %}, dir: {% iris_piece iris_portal.instance delimiter="*" num=0 %}
@register.simple_tag
def piece(value,  *args, **kwargs):
    delimiter = kwargs['delimiter']
    num = kwargs['num']
    return value.split(delimiter)[num]

# <p>Instance: {% iris_piece iris_portal.instance "*" 1 %}, dir: {% iris_piece iris_portal.instance "*" 0 %} 
@register.simple_tag
def iris_piece(value, delim, num):
    return value.split(delim)[num]

def is_empty(value, alt):
   if value:
       return value
   return alt

register.filter('is_empty', is_empty)