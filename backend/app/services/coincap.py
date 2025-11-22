from __future__ import annotations

import asyncio
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Iterable, List, Optional

import httpx
from fastapi import HTTPException, status

from ..config import settings


def _build_headers() -> Dict[str, str]:
    headers: Dict[str, str] = {"Accept": "application/json"}
    if settings.coincap_api_key:
        headers["Authorization"] = f"Bearer {settings.coincap_api_key}"
    return headers


async def _get_from_coincap(endpoint: str, params: Optional[Dict[str, Any]] = None) -> Any:
    url = f"{settings.coincap_base_url.rstrip('/')}/{endpoint.lstrip('/')}"
    try:
        async with httpx.AsyncClient(timeout=20.0, headers=_build_headers()) as client:
            response = await client.get(url, params=params)
    except httpx.RequestError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to reach CoinCap: {exc}",
        ) from exc

    if response.status_code == 429:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="CoinCap rate limit exceeded, please retry later",
        )

    if response.status_code >= 400:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"CoinCap API error: {response.text}",
        )

    data = response.json()
    if isinstance(data, dict) and "data" in data:
        return data["data"]
    return data


async def fetch_top_assets(limit: int = 10) -> List[Dict[str, Any]]:
    payload = await _get_from_coincap("assets", params={"limit": limit})
    return [item for item in payload if isinstance(item, dict)]


async def fetch_assets(search: Optional[str] = None, limit: int = 50) -> List[Dict[str, Any]]:
    params = {"limit": limit}
    payload = await _get_from_coincap("assets", params=params)
    items = [item for item in payload if isinstance(item, dict)]
    if search:
        search_lower = search.lower()
        items = [
            item
            for item in items
            if search_lower in str(item.get("name", "")).lower()
            or search_lower in str(item.get("symbol", "")).lower()
        ]
    return items


async def fetch_asset(asset_id: str) -> Dict[str, Any]:
    payload = await _get_from_coincap(f"assets/{asset_id}")
    if not isinstance(payload, dict):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Asset '{asset_id}' not found",
        )
    return payload


async def fetch_assets_by_ids(asset_ids: Iterable[str]) -> Dict[str, Dict[str, Any]]:
    asset_list = list({asset_id for asset_id in asset_ids if asset_id})
    if not asset_list:
        return {}

    async def _fetch_single(asset_id: str) -> Optional[Dict[str, Any]]:
        try:
            return await fetch_asset(asset_id)
        except HTTPException:
            return None

    results = await asyncio.gather(*[_fetch_single(asset_id) for asset_id in asset_list])
    return {
        asset_id: asset
        for asset_id, asset in zip(asset_list, results, strict=False)
        if asset is not None
    }


async def fetch_history(asset_id: str, days: int = 7) -> List[Dict[str, Any]]:
    now = datetime.now(timezone.utc)
    start = now - timedelta(days=days)
    params = {
        "interval": "d1",
        "start": int(start.timestamp() * 1000),
        "end": int(now.timestamp() * 1000),
    }
    payload = await _get_from_coincap(f"assets/{asset_id}/history", params=params)
    return [item for item in payload if isinstance(item, dict)]
