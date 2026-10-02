from django.http.response import JsonResponse
from django.shortcuts import redirect


def redirect_to_web(request):
    return redirect("web/")


def health_check(request):
    return JsonResponse({"status": "ok"})
