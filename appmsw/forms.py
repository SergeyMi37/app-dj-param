from django.forms import ModelForm, Textarea, TextInput
from appmsw.models import Param, Comment
from django.contrib.auth.models import User
from django.forms import CharField, PasswordInput
from django.core.exceptions import ValidationError


class ParamForm(ModelForm):
    class Meta:
        model = Param
        # Описываем поля, которые будем заполнять в форме
        fields = ['name', 'lang', 'public','code']
        widgets = {
            'name': TextInput(attrs={"placeholder": "Название сниппета", "class": "blue"}),
            'code': Textarea(attrs={"placeholder": "Код сниппета",'rows':13, 'cols':80}),
        }
        labels = {
            'name': '',
            'lang': '',
            'code': ''
        }


class UserRegistrationForm(ModelForm):
    class Meta:
        model = User
        fields = ["username", "email"]

    password1 = CharField(label="password", widget=PasswordInput) #***
    password2 = CharField(label="password confirm", widget=PasswordInput)

    # clean_имяПоля - проверка
    def clean_password2(self):  # кастомный валидатор
        pass1 = self.cleaned_data.get("password1")
        pass2 = self.cleaned_data.get("password2")
        if pass1 and pass2 and pass1 == pass2:
            return pass2 #возвращаем это же поле
        raise ValidationError("Пароли не совпадают или пустые")

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user


class CommentForm(ModelForm):
   class Meta:
       model = Comment
       fields = ['text']