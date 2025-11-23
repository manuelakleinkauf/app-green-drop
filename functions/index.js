const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();

/**
 * Função para geocodificar um endereço usando a API Nominatim
 * Recebe: { address: string }
 * Retorna: { latitude: number, longitude: number, displayName: string }
 */
exports.geocodeAddress = functions.https.onCall(async (data, context) => {
  try {
    const { address } = data;

    if (!address || typeof address !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'O endereço é obrigatório e deve ser uma string'
      );
    }

    // Faz a requisição para a API Nominatim
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(address)}&format=json&limit=1`;
    
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'GreenDropApp/1.0',
      },
    });

    if (!response.ok) {
      throw new functions.https.HttpsError(
        'internal',
        'Erro ao fazer a requisição para o serviço de geocodificação'
      );
    }

    const data_result = await response.json();

    if (!data_result || data_result.length === 0) {
      throw new functions.https.HttpsError(
        'not-found',
        'Endereço não encontrado'
      );
    }

    const result = data_result[0];

    return {
      latitude: parseFloat(result.lat),
      longitude: parseFloat(result.lon),
      displayName: result.display_name,
    };
  } catch (error) {
    console.error('Erro na geocodificação:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Erro ao processar a geocodificação'
    );
  }
});
