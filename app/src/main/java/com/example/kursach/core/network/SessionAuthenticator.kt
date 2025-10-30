package com.example.kursach.core.network

import com.example.kursach.core.storage.SessionStorage
import okhttp3.Authenticator
import okhttp3.Request
import okhttp3.Response
import okhttp3.Route
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SessionAuthenticator @Inject constructor(
    private val sessionStorage: SessionStorage,
) : Authenticator {

    override fun authenticate(route: Route?, response: Response): Request? {
        if (responseCount(response) >= MAX_RETRY_COUNT) {
            return null
        }
        sessionStorage.clear()
        return null
    }

    private fun responseCount(response: Response): Int {
        var currentResponse: Response? = response
        var result = 1
        while (currentResponse?.priorResponse != null) {
            result++
            currentResponse = currentResponse.priorResponse
        }
        return result
    }

    private companion object {
        private const val MAX_RETRY_COUNT = 1
    }
}
