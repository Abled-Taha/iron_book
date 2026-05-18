from django.contrib import admin
from django.contrib.staticfiles.storage import staticfiles_storage
from django.urls import path, include, re_path
from django.views.generic.base import RedirectView
from django.views.generic import TemplateView
from django.conf import settings
from iron_book import views

urlpatterns = [
    re_path(r'^favicon\.ico$', RedirectView.as_view(url=staticfiles_storage.url('img/favicon.png'), permanent=True)),
    path('robots.txt', TemplateView.as_view(template_name='robots.txt', content_type='text/plain')),
    path('admin/', admin.site.urls),
    path('web/', include('web.urls')),
    path('', views.redirect_to_web),
]

if settings.DEBUG:
    # Include django browser reload URLs only in debug mode
    urlpatterns += [path("__reload__/", include("django_browser_reload.urls")),]