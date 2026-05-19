# backend/app/api/v1/cms/pages.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

class PageContent(BaseModel):
    title: str
    content: str
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    published: bool = True

class BlogPost(BaseModel):
    title: str
    slug: str
    content: str
    excerpt: str
    author: str
    tags: List[str] = []
    published: bool = True

PAGES_FILE = "/app/data/cms_pages.json"
BLOG_FILE = "/app/data/blog_posts.json"

os.makedirs("/app/data", exist_ok=True)

def load_pages():
    if os.path.exists(PAGES_FILE):
        with open(PAGES_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_pages(pages):
    with open(PAGES_FILE, 'w') as f:
        json.dump(pages, f, indent=2)

def load_blog_posts():
    if os.path.exists(BLOG_FILE):
        with open(BLOG_FILE, 'r') as f:
            return json.load(f)
    return []

def save_blog_posts(posts):
    with open(BLOG_FILE, 'w') as f:
        json.dump(posts, f, indent=2)

@router.get("/pages/{page_id}")
async def get_page(page_id: str):
    pages = load_pages()
    if page_id not in pages:
        raise HTTPException(status_code=404, detail="Page not found")
    return pages[page_id]

@router.put("/pages/{page_id}")
async def update_page(page_id: str, page: PageContent):
    pages = load_pages()
    pages[page_id] = page.dict()
    save_pages(pages)
    return {"status": "updated", "page_id": page_id}

@router.post("/blog")
async def create_blog_post(post: BlogPost):
    posts = load_blog_posts()
    new_post = post.dict()
    new_post["id"] = len(posts) + 1
    new_post["created_at"] = datetime.now().isoformat()
    posts.append(new_post)
    save_blog_posts(posts)
    return new_post

@router.get("/blog")
async def list_blog_posts():
    return load_blog_posts()

@router.get("/blog/{slug}")
async def get_blog_post(slug: str):
    posts = load_blog_posts()
    for post in posts:
        if post.get("slug") == slug:
            return post
    raise HTTPException(status_code=404, detail="Post not found")
